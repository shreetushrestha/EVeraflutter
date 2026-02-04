import express from "express";
import { createBooking, getUserBookings, updateBookingStatus } from "../controllers/booking.controller.js";

const bookingRouter = express.Router();

bookingRouter.post("/", createBooking);
bookingRouter.get("/user/:userId", getUserBookings);
bookingRouter.put("/status", updateBookingStatus);
export default bookingRouter;