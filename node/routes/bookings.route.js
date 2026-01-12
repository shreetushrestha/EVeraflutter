import express from "express";
import * as bookingController from "../controllers/booking.controller.js";
import authMiddleware from "../middlewares/auth.middleware.js";

const router = express.Router();

router.post(
  "/",
  authMiddleware,
  bookingController.createBooking
);

// placeholders for later
router.get("/payment-success", (req, res) => {
  res.send("Payment Success - To be handled");
});

router.get("/payment-failure", (req, res) => {
  res.send("Payment Failed");
});

export default router;
