🧠 1. [SERVICE] — Global settings
[SERVICE]
    Daemon       off
    Log_Level    info
    Parsers_File parsers.conf
    HTTP_Server  On
    HTTP_Listen  0.0.0.0
    HTTP_Port    2020

Field	Meaning
Daemon off	Background me mat chalao, foreground me run karo (useful in Docker).
Log_Level info	Fluent Bit khud ke logs kis level pe dikhaye (info/debug/error).
Parsers_File parsers.conf	Parser definitions yahan se read karega.
HTTP_Server On	Monitoring ke liye internal metrics web server enable karega.
HTTP_Listen 0.0.0.0	Sab IPs se HTTP access allow karega.
HTTP_Port 2020	Metrics endpoint chalega http://<ip>:2020.

Ye port Fluent Bit ka internal monitoring endpoint ke liye hota hai —
basically ek HTTP status / metrics server hota hai, jisse aap check kar sakte ho ki Fluent Bit chal raha hai ya nahi, aur uska health / stats kya hai.

👉 Ye section basically Fluent Bit ke own control & monitoring interface setup karta hai.

📥 2. [INPUT] — Log sources (kahan se logs uthaye)
(a) Docker container logs
[INPUT]
    Name              tail
    Path              /var/lib/docker/containers/*/*.log
    Parser            docker
    Tag               docker.*
    Docker_Mode       On
    Refresh_Interval  2
    Mem_Buf_Limit     50MB
    Skip_Long_Lines   On

Field	Meaning
Name tail	File tailing input plugin use karega (file read karne ke liye).
Path	Docker ke container logs ka path.
Parser docker	parsers.conf me defined docker parser use karega (JSON format ke liye).
Tag docker.*	Is input ke saare logs “docker” tag ke saath jayenge.
Docker_Mode On	Docker JSON format ke logs ke liye optimize karega.
Refresh_Interval 2	Har 2 sec me naye file check karega.
Mem_Buf_Limit 50MB	50MB se zyada memory buffer use na kare.
Skip_Long_Lines On	Bahut lambe log lines skip karega.

👉 Ye section Docker container ke sab logs uthata hai.

(b) System logs (/var/log/syslog)
[INPUT]
    Name tail
    Path /var/log/syslog
    Parser syslog
    Tag syslog.*


👉 Ye section OS ke system-level logs collect karta hai.

(c) Auth logs (/var/log/auth.log)
[INPUT]
    Name tail
    Path /var/log/auth.log
    Parser authlog
    Tag authlog.*


👉 Ye system ke authentication logs collect karta hai (login attempts, SSH, etc.).

🧹 3. [FILTER] — Logs ko modify / enrich karna
(a) Parser filter
[FILTER]
    Name parser
    Match docker.*
    Key_Name log
    Parser docker
    Reserve_Data On


➡️ Docker log ke andar jo "log" field hai usko parse karke readable JSON bana deta hai.

(b) Clean blank lines
[FILTER]
    Name grep
    Match *
    Exclude message ^\s*$


➡️ Empty ya blank lines hata deta hai taaki clean output mile.

(c) Source label add karna
[FILTER]
    Name modify
    Match docker.*
    Add source docker


➡️ Har log me ek source=docker label add karega.

Similarly:

[FILTER]
    Name modify
    Match syslog.*
    Add source syslog


➡️ System logs ke liye source=syslog

📤 4. [OUTPUT] — Logs kahan bhejne hain
(a) Local console (debug purpose)
[OUTPUT]
    Name   stdout
    Match  *
    Format json_lines


➡️ Sab logs console me dikha deta hai (testing ke liye).

(b) Loki output (main destination)
[OUTPUT]
    Name              loki
    Match             *
    Host              172.31.21.163
    Port              3100
    URI               /loki/api/v1/push
    Labels            job=fluentbit,app=salary-api,env=prod,source=docker,container_job=docker
    Line_Format       json
    Log_Level         info

Field	Meaning
Name loki	Output plugin for Grafana Loki.
Match *	Sab inputs ke logs yahan jayenge.
Host/Port/URI	Loki service ka endpoint.
Labels	Ye Loki me searchable tags add karta hai (job, app, env, etc.).
Line_Format json	JSON format me bhejega.
Log_Level info	Fluent Bit → Loki communication logs info level tak dikhayega.
🎯 Result:

Tumhare Docker + System + Auth logs sab Loki me push ho rahe hain.

Grafana me tum query likh sakte ho:

{job="fluentbit"}

{app="salary-api"}

{source="docker"}

{container_job="docker"}
