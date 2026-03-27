import express from "express";
import { createBooking, getUserBookings, updateBookingStatus, getManagerBookings } from "../controllers/booking.controller.js";
import authMiddleware from "../middlewares/auth.middleware.js";

const bookingRouter = express.Router();

bookingRouter.post("/", createBooking);
bookingRouter.get("/user/:userId", getUserBookings);
bookingRouter.put("/status", updateBookingStatus);
bookingRouter.post("/update-status", updateBookingStatus);
bookingRouter.get("/manager-bookings", authMiddleware, getManagerBookings);

export default bookingRouter;