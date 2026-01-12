import mongoose from "mongoose";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/user.models.js";
import ChargingStation from "../models/station.model.js";
import { JWT_SECRET, JWT_EXPIRES_IN } from "../config/env.js";

/**
 * SIGN UP
 */
export const signUp = async (req, res, next) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const { name, email, phone, password, role } = req.body;

    if (!name || !email || !phone || !password) {
      throw new Error("All fields are required");
    }

    if (!/^\d{10}$/.test(phone)) {
      throw new Error("Phone number must be exactly 10 digits");
    }

    // ✅ Allow only specific roles from body
    const allowedRoles = ["user", "manager"];
    const assignedRole = allowedRoles.includes(role) ? role : "user";

    const existingUser = await User.findOne({ email });
    if (existingUser) throw new Error("User already exists");

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = await User.create(
      [{
        name,
        email,
        phone,
        password: hashedPassword,
        role: assignedRole // ✅ FIX
      }],
      { session }
    );

    const token = jwt.sign(
      { id: newUser[0]._id, role: newUser[0].role },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    await session.commitTransaction();
    session.endSession();

    res.status(201).json({
      success: true,
      message: "User created successfully",
      token,
      user: newUser[0]
    });

  } catch (error) {
    await session.abortTransaction();
    session.endSession();
    next(error);
  }
};


/**
 * LOGIN
 */
export const logIn = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const token = jwt.sign(
      { id: user._id, role: user.role },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    let stations = [];
    if (user.role === "manager") {
      stations = await ChargingStation.find({ manager: user._id });
    }

    res.status(200).json({
      success: true,
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role
      },
      stations
    });

  } catch (error) {
    next(error);
  }
};

/**
 * LOGOUT
 */
export const logOut = async (req, res, next) => {
  try {
    res.status(200).json({
      success: true,
      message: "Logged out successfully"
    });
  } catch (error) {
    next(error);
  }
};
