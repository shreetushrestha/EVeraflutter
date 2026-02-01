import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, "User Name is required"],
    trim: true,
    minLength: 3,
    maxLength: 30,
    match: [
      /^[A-Za-z ]+$/,
      "Name must contain only alphabets and spaces",
    ],
  },

  email: {
    type: String,
    required: [true, "User Email is required"],
    unique: true,
    trim: true,
    lowercase: true,
    match: [
      /^[a-zA-Z0-9._%+-]+@gmail\.com$/,
      "Email must be a valid @gmail.com address",
    ],
  },

  phone: {
    type: String,
    required: [true, "Phone number is required"],
    match: [
      /^\d{10}$/,
      "Phone number must be exactly 10 digits",
    ],
  },

  password: {
    type: String,
    required: [true, "User Password is required"],
    minLength: 6,
    match: [
      /^(?=.*[A-Z])(?=.*\d).{6,}$/,
      "Password must have at least 1 uppercase letter and 1 number",
    ],
  },

  role: {
    type: String,
    enum: ["admin", "manager", "user"],
    default: "user",
  },

  resetPasswordToken: {
    type: String,
  },

  resetPasswordExpires: {
    type: Date,
  },

}, { timestamps: true });

const User = mongoose.model("User", userSchema);
export default User;
