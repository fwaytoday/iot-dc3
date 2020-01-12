/*
  Copyright 2019 Pnoker. All Rights Reserved.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE `dc3`;

USE `dc3`;

-- ----------------------------
-- Table structure for dc3_group
-- ----------------------------
DROP TABLE IF EXISTS `dc3_group`;
CREATE TABLE `dc3_group`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '设备分组名称',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '描述',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `deleted` tinyint(4) NULL DEFAULT 0 COMMENT '逻辑删标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '设备分组表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dc3_driver
-- ----------------------------
DROP TABLE IF EXISTS `dc3_driver`;
CREATE TABLE `dc3_driver`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT ' 协议名称',
  `service_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '协议服务名称',
  `connect_info` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '设备驱动连接属性',
  `profile_info` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '设备位号配置属性',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '描述',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `deleted` tinyint(4) NULL DEFAULT 0 COMMENT '逻辑删标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dc3_profile
-- ----------------------------
DROP TABLE IF EXISTS `dc3_profile`;
CREATE TABLE `dc3_profile`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '模板名称',
  `share` tinyint(4) NULL DEFAULT 0 COMMENT '公有/私有模板标识',
  `config` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '位号配置信息，Json字符串',
  `driver_id` bigint(20) NOT NULL COMMENT '设备驱动ID',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '描述',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `deleted` tinyint(4) NULL DEFAULT 0 COMMENT '逻辑删标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name`) USING BTREE,
  INDEX `driver_id`(`driver_id`) USING BTREE,
  CONSTRAINT `dc3_profile_ibfk_1` FOREIGN KEY (`driver_id`) REFERENCES `dc3_driver` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '设备模板表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dc3_point
-- ----------------------------
DROP TABLE IF EXISTS `dc3_point`;
CREATE TABLE `dc3_point`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '位号名称',
  `type` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '数据类型：string\int\double\float\long\boolean',
  `rw` tinyint(4) NULL DEFAULT 0 COMMENT '读写标识：0读，1写，2读写',
  `value` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '--' COMMENT '默认值',
  `base` float NULL DEFAULT 0 COMMENT '基础值',
  `minimum` float NULL DEFAULT NULL COMMENT '最小值',
  `maximum` float NULL DEFAULT NULL COMMENT '最大值',
  `multiple` float(255, 0) NULL DEFAULT 1 COMMENT '倍数',
  `accrue` tinyint(4) NULL DEFAULT 0 COMMENT '累计标识',
  `format` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '格式数据，Jave格式 #.##',
  `unit` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '单位',
  `profile_id` bigint(20) NULL DEFAULT NULL COMMENT '模板ID',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '描述',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `deleted` tinyint(4) NULL DEFAULT 0 COMMENT '逻辑删标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `profile_id`(`profile_id`) USING BTREE,
  CONSTRAINT `dc3_point_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `dc3_profile` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '设备位号表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dc3_device
-- ----------------------------
DROP TABLE IF EXISTS `dc3_device`;
CREATE TABLE `dc3_device`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '设备名称',
  `code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '设备编码',
  `status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '设备状态（离线0，在线1，维护2，故障3，失效4）',
  `profile_id` bigint(20) NULL DEFAULT NULL COMMENT '模板ID',
  `group_id` bigint(20) NULL DEFAULT NULL COMMENT '设备分组ID',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '描述',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `deleted` tinyint(4) NULL DEFAULT 0 COMMENT '逻辑删标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name`) USING BTREE,
  UNIQUE INDEX `code`(`code`) USING BTREE,
  INDEX `profile_id`(`profile_id`) USING BTREE,
  INDEX `group_id`(`group_id`) USING BTREE,
  CONSTRAINT `dc3_device_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `dc3_profile` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `dc3_device_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `dc3_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '设备表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dc3_label
-- ----------------------------
DROP TABLE IF EXISTS `dc3_label`;
CREATE TABLE `dc3_label`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'label名称',
  `color` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '标签颜色',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '描述',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `deleted` tinyint(4) NULL DEFAULT 0 COMMENT '逻辑删标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '标签表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dc3_label_bind
-- ----------------------------
DROP TABLE IF EXISTS `dc3_label_bind`;
CREATE TABLE `dc3_label_bind`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `label_id` bigint(20) NOT NULL COMMENT '标签ID',
  `entity_id` bigint(20) NOT NULL COMMENT '实体ID，可为设备、设备组、模板、点位、用户',
  `type` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '关联实体类型，user\device\profile\group\point',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '描述',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `deleted` tinyint(4) NULL DEFAULT 0 COMMENT '逻辑删标识',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `label_id`(`label_id`) USING BTREE,
  INDEX `entity_id`(`entity_id`) USING BTREE,
  CONSTRAINT `dc3_label_bind_ibfk_1` FOREIGN KEY (`label_id`) REFERENCES `dc3_label` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '标签关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dc3_rtmp
-- ----------------------------
DROP TABLE IF EXISTS `dc3_rtmp`;
CREATE TABLE `dc3_rtmp`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '名称',
  `rtsp_url` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '源视频链接，在线视频或本地文件',
  `rtmp_url` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT 'rtp播放链接,填写后缀即可',
  `command` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT 'cmd运行模板',
  `video_type` tinyint(4) NULL DEFAULT 0 COMMENT '摄像头类型',
  `run` tinyint(4) NULL DEFAULT 0 COMMENT '状态，0停止，1启动',
  `auto_start` tinyint(4) NULL DEFAULT 0 COMMENT '自启动',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '描述',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `deleted` tinyint(4) NULL DEFAULT 0 COMMENT '逻辑删标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'rtmp表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dc3_rtmp
-- ----------------------------
INSERT INTO `dc3_rtmp` VALUES (-2, '在线测试视频', 'http://vfx.mtime.cn/Video/2019/03/19/mp4/190319104618910544.mp4', 'rtmp://dc3.nginx:1935/rtmp/190314223540373995_online', '{exe} -re -stream_loop -1 -i {rtsp_url} -vcodec copy -acodec copy -f flv -y {rtmp_url}', 0, 0, 0, '在线视频流（无限动力预告），用于测试使用', '2019-10-01 00:00:00', '2019-10-01 00:00:00', 0);
INSERT INTO `dc3_rtmp` VALUES (-1, '本地测试视频', 'D:/FFmpeg/bin/190314223540373995.mp4', 'rtmp://dc3.nginx:1935/rtmp/190314223540373995_local', '{exe} -re -stream_loop -1 -i {rtsp_url} -vcodec copy -acodec copy -f flv -y {rtmp_url}', 0, 0, 0,'本地MP4视频文件（复仇者联盟预告），用于测试使用', '2019-10-01 00:00:00', '2019-10-01 00:00:00', 0);

-- ----------------------------
-- Table structure for dc3_schedule
-- ----------------------------
DROP TABLE IF EXISTS `dc3_schedule`;
CREATE TABLE `dc3_schedule`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '任务名称',
  `corn_expression` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '定时任务规则',
  `status` tinyint(4) NULL DEFAULT 0 COMMENT '当前状态',
  `url` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '链接',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '描述',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `deleted` tinyint(4) NULL DEFAULT 0 COMMENT '逻辑删标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '任务调度表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dc3_user
-- ----------------------------
DROP TABLE IF EXISTS `dc3_user`;
CREATE TABLE `dc3_user`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '用户名，需要加密存储，均可用于登录',
  `password` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '密码，需要加密存储',
  `enable` tinyint(4) NULL DEFAULT 1 COMMENT '是否可用',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '描述',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `deleted` tinyint(4) NULL DEFAULT 0 COMMENT '逻辑删标识',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dc3_user
-- ----------------------------
INSERT INTO `dc3_user` VALUES (-1, 'pnoker', 'dc3dc3dc3', 1, '平台开发者账号', '2019-10-01 00:00:00', '2019-10-01 00:00:00', 0);

SET FOREIGN_KEY_CHECKS = 1;