const { PrismaClient } = require("@prisma/client");

// Single shared PrismaClient instance.
// Every controller should require THIS file instead of creating its own
// `new PrismaClient()` — creating multiple clients opens multiple connection
// pools and can exhaust MySQL connections, especially on Railway's free tier.
const prisma = new PrismaClient();

module.exports = prisma;
