import urllib.request
import os

print("Fetching D3.js...")
try:
    # We use cdnjs as it is generally more reliable than d3js.org
    url = "https://cdnjs.cloudflare.com/ajax/libs/d3/7.8.5/d3.min.js"
    urllib.request.urlretrieve(url, "d3.js")
    print("SUCCESS: 'd3.js' has been saved to your folder.")
except Exception as e:
    print(f"FAILURE: Could not download D3. Error: {e}")