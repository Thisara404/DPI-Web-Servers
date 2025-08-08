import http.server
import socketserver
import urllib.parse
import webbrowser
from urllib.parse import parse_qs, urlparse

class OAuthCallbackHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith('/callback'):
            # Parse the URL and extract query parameters
            parsed_url = urlparse(self.path)
            query_params = parse_qs(parsed_url.query)
            
            code = query_params.get('code', [None])[0]
            state = query_params.get('state', [None])[0]
            error = query_params.get('error', [None])[0]
            
            # Send response
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
            if error:
                html_content = f"""
                <!DOCTYPE html>
                <html>
                <head>
                    <title>OAuth Error</title>
                    <style>
                        body {{ font-family: Arial, sans-serif; margin: 50px; }}
                        .error {{ color: #dc3545; background: #f8d7da; padding: 20px; border-radius: 5px; }}
                    </style>
                </head>
                <body>
                    <div class="error">
                        <h2>❌ OAuth Error</h2>
                        <p><strong>Error:</strong> {error}</p>
                        <p><strong>Description:</strong> {query_params.get('error_description', ['Unknown error'])[0]}</p>
                    </div>
                </body>
                </html>
                """
            elif code:
                html_content = f"""
                <!DOCTYPE html>
                <html>
                <head>
                    <title>OAuth Success</title>
                    <style>
                        body {{ font-family: Arial, sans-serif; margin: 50px; }}
                        .success {{ color: #28a745; background: #d4edda; padding: 20px; border-radius: 5px; }}
                        .code-box {{ background: #f8f9fa; padding: 15px; margin: 10px 0; border-left: 4px solid #007bff; font-family: monospace; }}
                        button {{ background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; margin: 5px; }}
                    </style>
                </head>
                <body>
                    <div class="success">
                        <h2>✅ OAuth Authorization Successful!</h2>
                        <p><strong>Authorization Code:</strong></p>
                        <div class="code-box" id="authCode">{code}</div>
                        <p><strong>State:</strong> {state}</p>
                        <p><strong>Expires:</strong> 10 minutes from now</p>
                        <button onclick="copyCode()">Copy Code</button>
                    </div>
                    <script>
                        function copyCode() {{
                            navigator.clipboard.writeText('{code}').then(() => {{
                                alert('Authorization code copied to clipboard!');
                            }});
                        }}
                        console.log('Authorization Code:', '{code}');
                        console.log('State:', '{state}');
                    </script>
                </body>
                </html>
                """
                print(f"\n✅ OAuth Authorization Code Received: {code}")
                print(f"🔑 State: {state}")
                print("📋 Copy this code for your token exchange request\n")
            else:
                html_content = """
                <!DOCTYPE html>
                <html>
                <head>
                    <title>OAuth Callback</title>
                    <style>
                        body { font-family: Arial, sans-serif; margin: 50px; }
                        .info { color: #0c5460; background: #d1ecf1; padding: 20px; border-radius: 5px; }
                    </style>
                </head>
                <body>
                    <div class="info">
                        <h2>🔐 OAuth Callback Server</h2>
                        <p>Waiting for OAuth redirect...</p>
                        <p>This page should be reached via OAuth authorization redirect.</p>
                    </div>
                </body>
                </html>
                """
            
            self.wfile.write(html_content.encode())
        else:
            # Serve the default page
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            html_content = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>OAuth Callback Server</title>
                <style>
                    body { font-family: Arial, sans-serif; margin: 50px; text-align: center; }
                    .container { max-width: 600px; margin: 0 auto; }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>🔐 OAuth Callback Server</h1>
                    <p>Server is running and ready to receive OAuth callbacks.</p>
                    <p><strong>Callback URL:</strong> http://localhost:3000/callback</p>
                    <p>Use this URL as your redirect_uri in OAuth requests.</p>
                </div>
            </body>
            </html>
            """
            self.wfile.write(html_content.encode())

if __name__ == "__main__":
    PORT = 3000
    
    print("🚀 Starting OAuth Callback Server...")
    print(f"📝 Server URL: http://localhost:{PORT}")
    print(f"🔗 Callback URL: http://localhost:{PORT}/callback")
    print("🛑 Press Ctrl+C to stop the server")
    print("-" * 50)
    
    try:
        with socketserver.TCPServer(("", PORT), OAuthCallbackHandler) as httpd:
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except OSError as e:
        if e.errno == 10048:  # Port already in use
            print(f"❌ Port {PORT} is already in use. Please stop the other server first.")
        else:
            print(f"❌ Error starting server: {e}")
