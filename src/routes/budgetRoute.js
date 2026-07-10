const express = require("express");
const router = express.Router();

const budgetController = require("../controllers/budgetController");
const { requireAuth } = require("../middleware/auth");

router.use(requireAuth);

router.get("/", budgetController.getBudgets);
router.post("/", budgetController.createBudget);
router.put("/:id", budgetController.updateBudget);
router.delete("/:id", budgetController.deleteBudget);

module.exports = router;
