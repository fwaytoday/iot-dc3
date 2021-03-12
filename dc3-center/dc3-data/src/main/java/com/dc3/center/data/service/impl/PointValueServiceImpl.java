/*
 * Copyright 2018-2020 Pnoker. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.dc3.center.data.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.dc3.api.center.manager.feign.DeviceClient;
import com.dc3.center.data.service.PointValueService;
import com.dc3.common.bean.Pages;
import com.dc3.common.bean.R;
import com.dc3.common.constant.Common;
import com.dc3.common.dto.PointValueDto;
import com.dc3.common.exception.ServiceException;
import com.dc3.common.model.Device;
import com.dc3.common.model.PointValue;
import com.dc3.common.utils.RedisUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;
import java.util.concurrent.ThreadPoolExecutor;

/**
 * @author pnoker
 */
@Slf4j
@Service
public class PointValueServiceImpl implements PointValueService {

    @Resource
    private RedisUtil redisUtil;
    @Resource
    private MongoTemplate mongoTemplate;
    @Resource
    private ThreadPoolExecutor threadPoolExecutor;

    @Resource
    private DeviceClient deviceClient;

    @Override
    public List<PointValue> realtime(Long deviceId) {
        String key = Common.Cache.REAL_TIME_VALUES_KEY_PREFIX + deviceId;
        List<PointValue> pointValues = redisUtil.getKey(key, List.class);
        if (null == pointValues) {
            throw new ServiceException("No realtime value, Please use '/latest' to get the final data");
        }
        return pointValues;
    }

    @Override
    public PointValue realtime(Long deviceId, Long pointId) {
        String key = Common.Cache.REAL_TIME_VALUE_KEY_PREFIX + deviceId + "_" + pointId;
        PointValue pointValue = redisUtil.getKey(key, PointValue.class);
        if (null == pointValue) {
            throw new ServiceException("No realtime value, Please use '/latest' to get the final data");
        }
        return pointValue;
    }

    @Override
    public PointValue latest(Long deviceId, Long pointId) {
        R<Device> r = deviceClient.selectById(deviceId);
        if (!r.isOk()) {
            return null;
        }

        Criteria criteria = new Criteria();
        criteria.and("deviceId").is(deviceId);
        if (r.getData().getMulti()) {
            criteria.and("multi").is(true);
            if (null != pointId) {
                criteria.and("children").elemMatch(
                        (new Criteria()).and("pointId").is(pointId)
                );
            }
        } else if (null != pointId) {
            criteria.and("pointId").is(pointId);
        }

        Query query = new Query(criteria);
        query.with(Sort.by(Sort.Direction.DESC, "originTime"));
        return mongoTemplate.findOne(query, PointValue.class);
    }

    @Override
    public void addPointValue(PointValue pointValue) {
        if (null != pointValue) {
            savePointValueToRedis(pointValue.setCreateTime(System.currentTimeMillis()));
            mongoTemplate.insert(pointValue);
        }
    }

    @Override
    public void addPointValues(List<PointValue> pointValues) {
        if (null != pointValues) {
            if (pointValues.size() > 0) {
                pointValues.forEach(pointValue -> pointValue.setCreateTime(System.currentTimeMillis()));
                savePointValuesToRedis(pointValues);
                mongoTemplate.insert(pointValues, PointValue.class);
            }
        }
    }

    @Override
    public Page<PointValue> list(PointValueDto pointValueDto) {
        Criteria criteria = new Criteria();
        if (null == pointValueDto) {
            pointValueDto = new PointValueDto();
        }
        if (null != pointValueDto.getDeviceId()) {
            criteria.and("deviceId").is(pointValueDto.getDeviceId());
            R<Device> r = deviceClient.selectById(pointValueDto.getDeviceId());
            if (r.isOk()) {
                if (r.getData().getMulti()) {
                    criteria.and("multi").is(true);
                    if (null != pointValueDto.getPointId()) {
                        criteria.and("children").elemMatch(
                                (new Criteria()).and("pointId").is(pointValueDto.getPointId())
                        );
                    }
                } else if (null != pointValueDto.getPointId()) {
                    criteria.and("pointId").is(pointValueDto.getPointId());
                }
            }
        } else if (null != pointValueDto.getPointId()) {
            criteria.orOperator(
                    (new Criteria()).and("pointId").is(pointValueDto.getPointId()),
                    (new Criteria()).and("children").elemMatch((new Criteria()).and("pointId").is(pointValueDto.getPointId()))
            );
        }

        Pages pages = null == pointValueDto.getPage() ? new Pages() : pointValueDto.getPage();
        if (pages.getStartTime() > 0 && pages.getEndTime() > 0 && pages.getStartTime() <= pages.getEndTime()) {
            criteria.and("originTime").gte(pages.getStartTime()).lte(pages.getEndTime());
        }

        Query query = new Query(criteria);
        long count = mongoTemplate.count(query, PointValue.class);

        query.with(Sort.by(Sort.Direction.DESC, "originTime"));
        int size = (int) pages.getSize();
        long page = pages.getCurrent();
        query.limit(size).skip(size * (page - 1));

        List<PointValue> pointValues = mongoTemplate.find(query, PointValue.class);

        long id = 0L;
        for (PointValue pointValue1 : pointValues) {
            pointValue1.setId(id);
            id++;
            if (null != pointValue1.getChildren()) {
                for (PointValue pointValue2 : pointValue1.getChildren()) {
                    pointValue2.setId(id);
                    id++;
                }
            }
        }
        return (new Page<PointValue>()).setCurrent(pages.getCurrent()).setSize(pages.getSize()).setTotal(count).setRecords(pointValues);
    }

    /**
     * Save point value to redis
     *
     * @param pointValue Point Value
     */
    private void savePointValueToRedis(final PointValue pointValue) {
        threadPoolExecutor.execute(() -> {
            String pointIdKey = pointValue.getPointId() != null ? String.valueOf(pointValue.getPointId()) : Common.Cache.ASTERISK;
            // Save point value to Redis
            redisUtil.setKey(
                    Common.Cache.REAL_TIME_VALUE_KEY_PREFIX + pointValue.getDeviceId() + Common.Cache.DOT + pointIdKey,
                    pointValue,
                    pointValue.getTimeOut(),
                    pointValue.getTimeUnit()
            );
        });
    }

    /**
     * Save point value array to redis
     *
     * @param pointValues Point Value Array
     */
    private void savePointValuesToRedis(final List<PointValue> pointValues) {
        threadPoolExecutor.execute(() -> pointValues.forEach(pointValue -> {
            String pointIdKey = pointValue.getPointId() != null ? String.valueOf(pointValue.getPointId()) : Common.Cache.ASTERISK;
            // Save point value to Redis
            redisUtil.setKey(
                    Common.Cache.REAL_TIME_VALUE_KEY_PREFIX + pointValue.getDeviceId() + Common.Cache.DOT + pointIdKey,
                    pointValue,
                    pointValue.getTimeOut(),
                    pointValue.getTimeUnit()
            );
        }));
    }

}
