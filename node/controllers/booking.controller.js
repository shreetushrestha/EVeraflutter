import Booking from "../models/booking.model.js";

exports.createBooking = async (req, res) => {
  try {
    const { stationId, date, duration } = req.body;
    const userId = req.user.id; // from auth middleware

    if (!stationId || !date || !duration) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const amount = duration * 12;

    const booking = await Booking.create({
      userId,
      stationId,
      date,
      duration,
      amount,
      status: "PENDING",
    });

    const paymentUrl = generateEsewaUrl(booking);

    res.status(201).json({
      message: "Booking created",
      bookingId: booking._id,
      paymentUrl,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};

const generateEsewaUrl = (booking) => {
  const params = new URLSearchParams({
    amt: booking.amount,
    psc: 0,
    pdc: 0,
    txAmt: 0,
    tAmt: booking.amount,
    pid: booking._id.toString(),
    scd: "EPAYTEST", 
    su: "http://localhost:5000/api/bookings/payment-success",
    fu: "http://localhost:5000/api/bookings/payment-failure",
  });

  return `https://uat.esewa.com.np/epay/main?${params.toString()}`;
};
