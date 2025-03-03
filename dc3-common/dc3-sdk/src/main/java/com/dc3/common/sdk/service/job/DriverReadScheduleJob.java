/*
 * Copyright 2016-2021 Pnoker. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.dc3.common.sdk.service.job;

import com.dc3.common.bean.driver.AttributeInfo;
import com.dc3.common.model.Device;
import com.dc3.common.model.Point;
import com.dc3.common.sdk.bean.driver.DriverContext;
import com.dc3.common.sdk.service.DriverCommandService;
import lombok.extern.slf4j.Slf4j;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.springframework.scheduling.quartz.QuartzJobBean;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ThreadPoolExecutor;

/**
 * Read Schedule Job
 *
 * @author pnoker
 */
@Slf4j
@Component
public class DriverReadScheduleJob extends QuartzJobBean {

    @Resource
    private DriverContext driverContext;
    @Resource
    private ThreadPoolExecutor threadPoolExecutor;
    @Resource
    private DriverCommandService driverCommandService;

    @Override
    protected void executeInternal(JobExecutionContext jobExecutionContext) throws JobExecutionException {
        Map<Long, Device> deviceMap = driverContext.getDriverMetadata().getDeviceMap();
        deviceMap.values().forEach(device -> {
            Set<Long> profileIds = device.getProfileIds();
            Map<Long, Map<String, AttributeInfo>> pointInfoMap = driverContext.getDriverMetadata().getPointInfoMap().get(device.getId());
            if (null != pointInfoMap && null != profileIds) {
                profileIds.forEach(profileId -> {
                    Map<Long, Point> pointMap = driverContext.getDriverMetadata().getProfilePointMap().get(profileId);
                    if (null != pointMap) {
                        pointMap.keySet().forEach(pointId -> {
                            Map<String, AttributeInfo> map = pointInfoMap.get(pointId);
                            if (null != map) {
                                threadPoolExecutor.execute(() -> driverCommandService.read(device.getId(), pointId));
                            }
                        });
                    }
                });
            }
        });
    }
}