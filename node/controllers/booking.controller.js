import Booking from "../models/booking.models.js";

// Create a new booking
export const createBooking = async (req, res) => {
  try {
    const { userId, stationId, plug, startDateTime, duration, price } = req.body;

    if (!userId || !stationId || !startDateTime || !duration || !price) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const start = new Date(startDateTime);
    const end = new Date(start.getTime() + (duration === 0.5 ? 30 : duration * 60) * 60000);

    const booking = new Booking({
      user: userId,
      station: stationId,
      plug: plug || "",
      startDateTime: start,
      duration,
      endDateTime: end,
      price,
      status: "pending",
    });

    await booking.save();
    return res.status(201).json({ message: "Booking created", booking });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Get bookings for a user
export const getUserBookings = async (req, res) => {
  try {
    const userId = req.params.userId;
    const now = new Date();

    await Booking.updateMany(
      {
        user: userId,
        status: { $in: ["pending", "confirmed"] },
        endDateTime: { $lt: now }
      },
      {
        $set: { status: "completed" }
      }
    );

    await Booking.updateMany(
      {
        user: userId,
        status: "pending",
        startDateTime: { $lte: now },
        endDateTime: { $gt: now }
      },
      {
        $set: { status: "confirmed" }
      }
    );

    const bookings = await Booking.find({ user: userId })
      .populate("station")
      .sort({ startDateTime: -1 });

    res.json(bookings);

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};


// Update booking status (cancel, confirm)
export const updateBookingStatus = async (req, res) => {
  try {
    const { bookingId, status } = req.body;
    if (!["pending", "confirmed", "completed", "cancelled"].includes(status)) {
      return res.status(400).json({ message: "Invalid status" });
    }
    const booking = await Booking.findByIdAndUpdate(bookingId, { status }, { new: true });
    res.json({ message: "Booking updated", booking });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

