const express = require('express');
const path = require('path');

const app = express();
const PORT = 3000;

// Serve static files
app.use(express.static(__dirname));

// OAuth callback endpoint
app.get('/callback', (req, res) => {
    const { code, state, error, error_description } = req.query;
    
    if (error) {
        return res.send(`
            <h1>OAuth Error</h1>
            <p><strong>Error:</strong> ${error}</p>
            <p><strong>Description:</strong> ${error_description}</p>
        `);
    }
    
    if (code) {
        res.send(`
            <h1>✅ OAuth Authorization Successful!</h1>
            <p><strong>Authorization Code:</strong></p>
            <pre style="background: #f5f5f5; padding: 10px; border-radius: 4px;">${code}</pre>
            <p><strong>State:</strong> ${state}</p>
            <p>Copy this code and use it in your Postman OAuth Token Exchange request.</p>
            <script>
                console.log('Authorization Code:', '${code}');
                console.log('State:', '${state}');
            </script>
        `);
    } else {
        res.send(`
            <h1>❌ No Authorization Code Received</h1>
            <p>Please initiate OAuth flow properly.</p>
        `);
    }
});

// Health check
app.get('/health', (req, res) => {
    res.json({ 
        success: true, 
        message: 'OAuth Callback Server is running',
        port: PORT 
    });
});

// Default route
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'oauth-callback.html'));
});

app.listen(PORT, () => {
    console.log(`🚀 OAuth Callback Server running on http://localhost:${PORT}`);
    console.log(`📝 Callback URL: http://localhost:${PORT}/callback`);
    console.log(`🏠 Test page: http://localhost:${PORT}`);
});

module.exports = app;
