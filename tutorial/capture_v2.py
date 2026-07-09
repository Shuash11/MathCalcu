"""Capture app screenshots with longer wait times."""
import os, time
from playwright.sync_api import sync_playwright

SCREENSHOTS_DIR = os.path.join(os.path.dirname(__file__), "screenshots")
os.makedirs(SCREENSHOTS_DIR, exist_ok=True)

def capture():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True, args=["--disable-gpu", "--no-sandbox"])
        page = browser.new_page(viewport={"width": 1920, "height": 1080})
        
        print("Loading app...")
        page.goto("http://localhost:8080", wait_until="networkidle", timeout=60000)
        time.sleep(8)  # Wait for Flutter to fully render
        
        # Screenshot 1: Initial screen
        print("1. Initial screen...")
        page.screenshot(path=os.path.join(SCREENSHOTS_DIR, "01_initial.png"))
        
        # Check if there's an activation gate
        body_text = page.evaluate("document.body.innerText")
        print(f"  Body text: {body_text[:200]}")
        
        # Try clicking anywhere to activate
        page.click("body")
        time.sleep(3)
        page.screenshot(path=os.path.join(SCREENSHOTS_DIR, "02_after_click.png"))
        
        body_text = page.evaluate("document.body.innerText")
        print(f"  After click: {body_text[:200]}")
        
        # Try to find and click buttons
        buttons = page.locator("button, [role=button], .btn, .button")
        btn_count = buttons.count()
        print(f"\n  Found {btn_count} buttons")
        for i in range(min(btn_count, 10)):
            try:
                btn_text = buttons.nth(i).inner_text()
                print(f"    Button {i}: '{btn_text}'")
            except:
                pass
        
        # Look for any clickable elements
        clickables = page.locator("[onclick], a, .card, .tile, .module")
        print(f"\n  Found {clickables.count()} clickable elements")
        
        # Try direct navigation to specific routes
        routes = [
            ("/", "home"),
            ("/derivatives", "derivatives"),
            ("/limits", "limits"),
            ("/circles", "circles"),
            ("/distance", "distance"),
            ("/slope", "slope"),
            ("/inequalities", "inequalities"),
            ("/activation", "activation"),
        ]
        
        for route, name in routes:
            try:
                page.goto(f"http://localhost:8080{route}", wait_until="networkidle", timeout=15000)
                time.sleep(4)
                page.screenshot(path=os.path.join(SCREENSHOTS_DIR, f"route_{name}.png"))
                body_text = page.evaluate("document.body.innerText")
                print(f"  Route {route}: {body_text[:100]}")
            except Exception as e:
                print(f"  Route {route} error: {e}")
        
        browser.close()
        print("\nDone!")

if __name__ == "__main__":
    capture()
