"""Debug: see what's on the page."""
import time
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={"width": 1920, "height": 1080})
    page.goto("http://localhost:8080", wait_until="networkidle", timeout=30000)
    time.sleep(5)
    
    # Get all visible text
    texts = page.evaluate("""() => {
        const els = document.querySelectorAll('*');
        const texts = [];
        for (const el of els) {
            if (el.children.length === 0 && el.textContent.trim()) {
                texts.push(el.textContent.trim().substring(0, 80));
            }
        }
        return [...new Set(texts)];
    }""")
    
    print("Visible text elements:")
    for t in texts:
        print(f"  '{t}'")
    
    # Take a screenshot
    page.screenshot(path="C:/projects/mathcalcu/tutorial/screenshots/debug.png")
    
    browser.close()
