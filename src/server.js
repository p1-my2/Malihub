// dotenv MUST be loaded before anything else is required, since app.js
// (via jwt.js) reads process.env.JWT_SECRET at require-time.
require("dotenv").config();

const app = require("./app");

// Railway assigns its own port at runtime via process.env.PORT — never
// hardcode a port, or the app won't be reachable once deployed.
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
