import mongoose from "mongoose";

const BookingSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  station: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "ChargingStation",
    required: true
  },
  plug: { type: String }, // Type2, CCS, etc.
  startDateTime: { type: Date, required: true }, // start datetime
  duration: { type: Number, required: true }, // in hours, 0.5 for 30 min
  endDateTime: { type: Date, required: true }, // calculated automatically
  price: { type: Number, required: true }, // store as number
  status: {
    type: String,
enum: ["pending", "confirmed", "active", "completed", "cancelled"],
    default: "pending"
  },
}, { timestamps: true });

// Middleware to calculate endDateTime if not provided
BookingSchema.pre("validate", function(next) {
  if (!this.endDateTime && this.startDateTime && this.duration) {
    const minutes = this.duration === 0.5 ? 30 : this.duration * 60;
    this.endDateTime = new Date(this.startDateTime.getTime() + minutes * 60000);
  }
  next();
});

const Booking = mongoose.model("Booking", BookingSchema);
export default Booking;
