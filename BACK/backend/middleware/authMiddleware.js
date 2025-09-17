
const requireAuth = (req, res, next) => {
  // Get the secret key from a custom header
  const apiKey = req.headers['x-api-key'];

  // Check if the key matches the one in your .env file
  if (apiKey && apiKey === process.env.FLUTTER_API_KEY) {
    next(); // Key is valid, proceed
  } else {
    res.status(401).json({ error: 'Unauthorized: Invalid API Key' });
  }
};

export default requireAuth;