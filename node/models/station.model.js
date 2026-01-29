import mongoose from "mongoose";


const StationSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true
    },

    city: {
      type: String,
      required: true
    },

    province: {
      type: String,
      required: true
    },

    address: {
      type: String,
      required: true
    },

    telephone: {
      type: String
    },

    latitude: {
      type: Number,
      required: true
    },

    longitude: {
      type: Number,
      required: true
    },

    type: {
      type: [String], // e.g. ["Hotel", "Public"]
      default: []
    },

plugs: [
  {
    plug: { type: String, required: true },   // Type2, CCS, CHAdeMO
    power: { type: String, required: true },  // 7.2kW, 50kW, 120kW
    type: { type: String, required: true }    // AC / DC
  }
],

    totalSlots: {
      type: Number,
      required: true,
      min: 1
    },

    // CURRENTLY available slots
    availableSlots: {
      type: Number,
      required: true,
      min: 0
    },

    amenities: {
      type: [String], // e.g. ["Restroom", "Cafe", "Parking"]
      default: []
    },
    
    image: {
      type: String
    },

    manager: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    }
  },

  {
    timestamps: true
  }

);


const Station = mongoose.model("ChargingStation", StationSchema);
export default Station;
