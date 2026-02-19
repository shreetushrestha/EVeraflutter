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

    plugs: {
      type: [
        {
          plug: { type: String, default: "" },   // Type2, CCS, CHAdeMO
          power: { type: String, default: "" },  // 7.2kW, 50kW, 120kW
          type: { type: String, default: "" }    // AC / DC
        }
      ],
      default: [] // if no plugs are provided
    },

    totalSlots: {
      type: Number,
      required: true,
      min: 1
    },

    availableSlots: {
      type: Number,
      required: true,
      min: 0
    },

    isOperational: {
      type: Boolean,
      default: true
    },


    amenities: {
      type: [String],
      default: []
    },

    images: {
      type: [String],
      default: []
    },

    price: {
      type: String,
      default: "Rs. 15/kWh",
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

