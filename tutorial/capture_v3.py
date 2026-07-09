"""Capture Flutter app screenshots with headed Chrome."""
import os, time, subprocess, signal
from playwright.sync_api import sync_playwright

SCREENSHOTS_DIR = os.path.join(os.path.dirname(__file__), "screenshots")
os.makedirs(SCREENSHOTS_DIR, exist_ok=True)

# Kill any existing server
def kill_server():
    subprocess.run(["taskkill", "/F", "/IM", "python.exe", "/FI", "WINDOWTITLE eq http.server*"],
                   capture_output=True)

def capture():
    # Start server
    server = subprocess.Popen(
        ["python", "-m", "http.server", "8080", "--directory", "C:/projects/mathcalcu/build/web"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )
    time.sleep(2)
    
    try:
        with sync_playwright() as p:
            # Launch with headed mode (visible browser) for Flutter web
            browser = p.chromium.launch(
                headless=False,
                args=[
                    "--disable-web-security",
                    "--use-gl=swiftshader",
                    "--enable-webgl",
                    "--ignore-gpu-blocklist"
                ]
            )
            page = browser.new_page(viewport={"width": 412, "height": 915})  # Phone size
            
            print("Loading app...")
            page.goto("http://localhost:8080", wait_until="networkidle", timeout=60000)
            time.sleep(10)  # Wait for Flutter to fully render
            
            # Screenshot 1: Initial/home screen
            print("1. Home screen...")
            page.screenshot(path=os.path.join(SCREENSHOTS_DIR, "01_home.png"))
            
            body = page.evaluate("document.body.innerText")
            print(f"  Text: {body[:150]}")
            
            # Try clicking to activate
            page.click("body")
            time.sleep(5)
            page.screenshot(path=os.path.join(SCREENSHOTS_DIR, "02_activated.png"))
            
            body = page.evaluate("document.body.innerText")
            print(f"  After activate: {body[:150]}")
            
            # Try clicking various areas
            for y in range(200, 800, 100):
                page.mouse.click(206, y)
                time.sleep(1)
            
            time.sleep(3)
            page.screenshot(path=os.path.join(SCREENSHOTS_DIR, "03_after_clicks.png"))
            
            body = page.evaluate("document.body.innerText")
            print(f"  After all clicks: {body[:200]}")
            
            browser.close()
    finally:
        server.terminate()
        server.wait()

if __name__ == "__main__":
    capture()
