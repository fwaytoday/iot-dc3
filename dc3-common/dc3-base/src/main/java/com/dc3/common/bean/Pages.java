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

package com.dc3.common.bean;

import com.baomidou.mybatisplus.core.metadata.OrderItem;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;
import org.springframework.beans.BeanUtils;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * 基础查询类，其中包括分页以及排序
 *
 * @author pnoker
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Accessors(chain = true)
public class Pages implements Serializable {
    private static final long serialVersionUID = 1L;

    private long current = 1;
    private long size = 20;
    private long startTime;
    private long endTime;
    private List<OrderItem> orders = new ArrayList<>(4);

    public <T> Page<T> convert() {
        Page<T> page = new Page<>();
        BeanUtils.copyProperties(this, page);

        boolean createTimeOrder = false;
        for (OrderItem order : page.orders()) {
            if (order.getColumn().equals("create_time")) {
                createTimeOrder = true;
            }
        }
        if (!createTimeOrder) {
            page.orders().add(OrderItem.desc("create_time"));
        }
        return page;
    }

}
