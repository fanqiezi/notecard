# 音符卡 R8 规则
# 目前没有需要显式 keep 的反射入口；drift / sqlite3 / soloud / midi 的 consumer rules 由插件自带。
# 如果后续接入需要反射的库（如某些 JSON 库），在这里补 -keep。
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**
