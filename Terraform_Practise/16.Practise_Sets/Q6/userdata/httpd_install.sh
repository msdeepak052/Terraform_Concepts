#!/bin/bash
dnf install -y httpd
systemctl enable httpd
systemctl start httpd

mkdir -p /opt/app

cat << 'PYEOF' > /opt/app/generate_page.py
#!/usr/bin/env python3
import urllib.request
import subprocess

WEB_ROOT = "/var/www/html"


def get_token():
    req = urllib.request.Request(
        "http://169.254.169.254/latest/api/token",
        method="PUT",
        headers={"X-aws-ec2-metadata-token-ttl-seconds": "21600"},
    )
    return urllib.request.urlopen(req).read().decode()


def get_meta(path, token):
    req = urllib.request.Request(
        "http://169.254.169.254/latest/meta-data/" + path,
        headers={"X-aws-ec2-metadata-token": token},
    )
    return urllib.request.urlopen(req).read().decode()


token = get_token()
instance_id = get_meta("instance-id", token)
hostname = subprocess.run(["hostname"], capture_output=True, text=True).stdout.strip()

try:
    public_dns = get_meta("public-hostname", token)
except Exception:
    public_dns = "N/A (no public IP assigned)"

html = f"""<!DOCTYPE html>
<html>
<head>
<title>DevopsWithDeepak</title>
<style>
  :root {{
    --bg-1: #0b0e14;
    --bg-2: #131a22;
    --bg-3: #1a2330;
    --aws-orange: #ff9900;
    --aws-orange-2: #ffac31;
    --card-bg: rgba(255, 255, 255, 0.05);
    --card-border: rgba(255, 153, 0, 0.35);
    --text-muted: #9aa5b1;
    --green: #2ecc71;
  }}

  * {{ box-sizing: border-box; }}

  body {{
    margin: 0;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: "Segoe UI", "Helvetica Neue", Arial, sans-serif;
    background: linear-gradient(135deg, var(--bg-1), var(--bg-2), var(--bg-3));
    background-size: 200% 200%;
    animation: gradientShift 12s ease infinite;
    color: #fff;
    padding: 24px;
  }}

  @keyframes gradientShift {{
    0%   {{ background-position: 0% 50%; }}
    50%  {{ background-position: 100% 50%; }}
    100% {{ background-position: 0% 50%; }}
  }}

  .card {{
    width: 100%;
    max-width: 640px;
    margin: 0 auto;
    background: var(--card-bg);
    border: 1px solid var(--card-border);
    border-radius: 18px;
    backdrop-filter: blur(14px);
    padding: 36px 40px;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5), 0 0 40px rgba(255, 153, 0, 0.06);
    text-align: left;
  }}

  h1 {{
    font-size: clamp(2rem, 6vw, 2.8rem);
    margin: 0 0 24px;
    font-weight: 800;
    text-align: center;
    background: linear-gradient(90deg, var(--aws-orange), var(--aws-orange-2));
    -webkit-background-clip: text;
    background-clip: text;
    color: transparent;
    letter-spacing: -1px;
  }}

  .status {{
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    margin: 0 0 26px;
  }}

  .dot {{
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: var(--green);
    animation: pulse 1.8s infinite;
  }}

  @keyframes pulse {{
    0%   {{ box-shadow: 0 0 0 0 rgba(46, 204, 113, 0.55); }}
    70%  {{ box-shadow: 0 0 0 12px rgba(46, 204, 113, 0); }}
    100% {{ box-shadow: 0 0 0 0 rgba(46, 204, 113, 0); }}
  }}

  .status span {{
    color: var(--green);
    font-weight: 600;
    font-size: 0.9rem;
    letter-spacing: 0.4px;
  }}

  .info-item {{
    font-family: "Consolas", "Courier New", monospace;
    background: rgba(255, 255, 255, 0.03);
    border: 1px solid rgba(255, 255, 255, 0.07);
    border-radius: 10px;
    padding: 12px 16px;
    margin-bottom: 12px;
  }}

  .info-label {{
    display: block;
    color: var(--aws-orange-2);
    font-weight: 600;
    text-transform: uppercase;
    font-size: 11px;
    letter-spacing: 0.8px;
    margin-bottom: 4px;
  }}

  .info-value {{
    color: #e6e9ee;
    font-size: 0.95rem;
    word-break: break-all;
  }}

  footer {{
    margin-top: 22px;
    text-align: center;
    color: var(--text-muted);
    font-size: 12px;
  }}
</style>
</head>
<body>
<div class="card">
  <h1>DevopsWithDeepak</h1>
  <div class="status"><span class="dot"></span><span>Instance is up and serving traffic</span></div>

  <div class="info-item">
    <span class="info-label">Instance ID</span>
    <span class="info-value">{instance_id}</span>
  </div>
  <div class="info-item">
    <span class="info-label">Hostname</span>
    <span class="info-value">{hostname}</span>
  </div>
  <div class="info-item">
    <span class="info-label">Public DNS</span>
    <span class="info-value">{public_dns}</span>
  </div>

  <footer>Deployed via user_data on boot &middot; Amazon Linux 2023 + httpd</footer>
</div>
</body>
</html>
"""

with open(f"{WEB_ROOT}/index.html", "w") as f:
    f.write(html)

subprocess.run(["chown", "apache:apache", f"{WEB_ROOT}/index.html"])
PYEOF

chmod +x /opt/app/generate_page.py
python3 /opt/app/generate_page.py
