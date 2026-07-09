"""Capture screenshots of MathCalcu app using Playwright."""
import os, time
from playwright.sync_api import sync_playwright

SCREENSHOTS_DIR = os.path.join(os.path.dirname(__file__), "screenshots")
os.makedirs(SCREENSHOTS_DIR, exist_ok=True)

def capture():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 1920, "height": 1080})
        
        # Navigate to app
        page.goto("http://localhost:8080", wait_until="networkidle", timeout=30000)
        time.sleep(3)
        
        # Screenshot 1: Home screen
        print("1. Home screen...")
        page.screenshot(path=os.path.join(SCREENSHOTS_DIR, "home.png"), full_page=False)
        
        # Look for category buttons / module cards
        # Try clicking on Derivatives
        print("2. Looking for Derivatives module...")
        try:
            # Try various selectors for the derivatives module
            deriv = page.locator("text=Derivative").first
            if deriv.is_visible():
                deriv.click()
                time.sleep(2)
                page.screenshot(path=os.path.join(SCREENSHOTS_DIR, "derivatives_screen.png"), full_page=False)
                
                # Try to find input field and type
                inputs = page.locator("input, TextField")
                if inputs.count() > 0:
                    inputs.first.fill("sin(x^2) + ln(cos(x))")
                    time.sleep(1)
                    page.screenshot(path=os.path.join(SCREENSHOTS_DIR, "deriv_input.png"), full_page=False)
                    
                    # Try to find and click solve button
                    solve = page.locator("text=Solve").first
                    if solve.is_visible():
                        solve.click()
                        time.sleep(2)
                        page.screenshot(path=os.path.join(SCREENSHOTS_DIR, "deriv_result.png"), full_page=False)
                
                # Go back
                page.go_back()
                time.sleep(1)
        except Exception as e:
            print(f"  Derivatives error: {e}")
        
        # Try clicking on Limits
        print("3. Looking for Limits module...")
        try:
            limits = page.locator("text=Limit").first
            if limits.is_visible():
                limits.click()
                time.sleep(2)
                page.screenshot(path=os.path.join(SCREENSHOTS_DIR, "limits_screen.png"), full_page=False)
                page.go_back()
                time.sleep(1)
        except Exception as e:
            print(f"  Limits error: {e}")
        
        # Try clicking on Circles
        print("4. Looking for Circles module...")
        try:
            circles = page.locator("text=Circle").first
            if circles.is_visible():
                circles.click()
                time.sleep(2)
                page.screenshot(path=os.path.join(SCREENSHOTS_DIR, "circles_screen.png"), full_page=False)
                page.go_back()
                time.sleep(1)
        except Exception as e:
            print(f"  Circles error: {e}")
        
        # Try clicking on Distance
        print("5. Looking for Distance module...")
        try:
            dist = page.locator("text=Distance").first
            if dist.is_visible():
                dist.click()
                time.sleep(2)
                page.screenshot(path=os.path.join(SCREENSHOTS_DIR, "distance_screen.png"), full_page=False)
                page.go_back()
                time.sleep(1)
        except Exception as e:
            print(f"  Distance error: {e}")
        
        # Go back to home and take final screenshot
        page.goto("http://localhost:8080", wait_until="networkidle", timeout=30000)
        time.sleep(2)
        page.screenshot(path=os.path.join(SCREENSHOTS_DIR, "home_final.png"), full_page=False)
        
        browser.close()
        
        # List captured screenshots
        print("\nCaptured screenshots:")
        for f in sorted(os.listdir(SCREENSHOTS_DIR)):
            if f.endswith(".png"):
                sz = os.path.getsize(os.path.join(SCREENSHOTS_DIR, f)) // 1024
                print(f"  {f} ({sz} KB)")

if __name__ == "__main__":
    capture()
