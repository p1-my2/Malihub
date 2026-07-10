const express = require("express");
const router = express.Router();

const transactionController = require("../controllers/transactionController");
const { requireAuth } = require("../middleware/auth");

router.use(requireAuth);

// IMPORTANT: /summary must be declared before /:id, otherwise Express
// matches "summary" as the :id param and this route never gets hit.
router.get("/summary", transactionController.getSummary);

router.get("/", transactionController.getTransactions);
router.get("/:id", transactionController.getTransaction);
router.post("/", transactionController.createTransaction);
router.put("/:id", transactionController.updateTransaction);
router.delete("/:id", transactionController.deleteTransaction);

module.exports = router;
