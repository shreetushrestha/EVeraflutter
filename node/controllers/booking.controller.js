import Booking from "../models/booking.models.js";
import Station from "../models/station.model.js";

export const createBooking = async (req, res) => {
  try {
    const { userId, stationId, plug, startDateTime, duration, price } = req.body;

    if (!userId || !stationId || !startDateTime || !duration || !price) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const station = await Station.findById(stationId);

    if (!station.isOperational) {
      return res.status(400).json({
        message: "Station is currently unavailable"
      });
    }

    if (!station) {
      return res.status(404).json({ message: "Station not found" });
    }

    if (!station.isOperational) {
      return res.status(400).json({
        message: "Station is currently unavailable (maintenance)"
      });
    }

    const start = new Date(startDateTime);
    const end = new Date(start.getTime() + (duration === 0.5 ? 30 : duration * 60) * 60000);

    // 🚨 2️⃣ Find overlapping bookings
    const overlappingBookings = await Booking.countDocuments({
      station: stationId,
      status: { $in: ["confirmed", "active"] },
      startDateTime: { $lt: end },
      endDateTime: { $gt: start }
    });

    // 🚨 3️⃣ If full, block booking
    if (overlappingBookings >= station.totalSlots) {
      return res.status(400).json({
        message: "No available slots for selected time"
      });
    }

    const booking = new Booking({
      user: userId,
      station: stationId,
      plug: plug || "",
      startDateTime: start,
      duration,
      endDateTime: end,
      price,
      status: "confirmed"
    });

    await booking.save();

    res.status(201).json({
      message: "Booking created successfully",
      booking
    });

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

export const autoUpdateBookings = async () => {
  const now = new Date();

  // 1️⃣ Start bookings
  const startingBookings = await Booking.find({
    status: "confirmed",
    startDateTime: { $lte: now },
    endDateTime: { $gt: now }
  });

  for (let booking of startingBookings) {
    await Station.findByIdAndUpdate(
      booking.station,
      { $inc: { availableSlots: -1 } }
    );

    booking.status = "completed";
    await booking.save();
  }

  // 2️⃣ End bookings
  const finishedBookings = await Booking.find({
    status: "completed",
    endDateTime: { $lte: now }
  });

  for (let booking of finishedBookings) {
    await Station.findByIdAndUpdate(
      booking.station,
      { $inc: { availableSlots: 1 } }
    );
  }
};