# WeGPT
Flutter 版本的ChatGPT，支持`iOS`、`Android`、`Windows`、`MACOS`、`Liniux`和`Web`。
后端使用Golang Fiber框架+GOGRPC开发。实现快速搭建ChatGPT聊天机器人。
`app`目录下是对应Flutter App段代码。
`Server`目录下是golang代码。
# 后端服务需要在MySQL中创建`gpt_app`数据库，然后使用sql 语句创建如下表：
#### 免费用户可用免费消息数
```sql
CREATE TABLE `free_usages` (
  `user_id` int NOT NULL,
  `message_count` int DEFAULT '5',
  `created_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

#### 用户邀请码
```sql
REATE TABLE `invite_codes` (
  `user_id` int NOT NULL,
  `code` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

#### 用户登录token
```sql
CREATE TABLE `tokens` (
  `user_id` int NOT NULL,
  `token` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

#### 聊天消息tokens
```sql
CREATE TABLE `token_usages` (
  `user_id` int NOT NULL,
  `token_used` int NOT NULL,
  `reset_date` date NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

#### 用户表
```sql
CREATE TABLE `users` (
  `id` int NOT NULL,
  `email` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inviter_id` int NOT NULL,
  `is_vip` int NOT NULL DEFAULT '0',
  `free_usage` int NOT NULL DEFAULT '10',
  `vip_started_at` timestamp NULL DEFAULT NULL,
  `vip_ended_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```
#### 登录验证码
```sql
CREATE TABLE `verify_codes` (
  `code` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `used` int NOT NULL DEFAULT '0',
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```
## 登录注册
<div align="center">
  <img src="https://github.com/UnivexDont/WeGPT/blob/main/images/login.png" alt="" width="414">
</div>

## 侧边栏
<div align="center">
  <img src="https://github.com/UnivexDont/WeGPT/blob/main/images/draw.png" alt="" width="414">
</div>

## 聊天页面
<div align="center">
  <img src="https://github.com/UnivexDont/WeGPT/blob/main/images/chating.png" alt="" width="414">
</div>
<div align="center">
  <img src="(https://github.com/UnivexDont/WeGPT/blob/main/images/changting2.png" alt="" width="414">
</div>

## 横屏
<div align="center">
  <img src="https://github.com/UnivexDont/WeGPT/blob/main/images/hor_screen.png" alt="" width="414">
</div>
<div align="center">
  <img src="https://github.com/UnivexDont/WeGPT/blob/main/images/hor_screen2.png" alt="" width="414">
</div>

## 主题切换
<div align="center">
  <img src="https://github.com/UnivexDont/WeGPT/blob/main/images/theme_change.png" alt="" width="414">
</div>

## 个人中心
<div align="center">
  <img src="https://github.com/UnivexDont/WeGPT/blob/main/images/profile.png" alt="" width="414">
</div>

## 除此之外还有
- 邀请码。
- 聊天窗口标题修改。
- 用户每天、每月最大token限制。
- 非VIP用户可免费享用的聊天条数。
- 等等。
