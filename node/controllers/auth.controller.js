import mongoose from "mongoose";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/user.models.js";
import ChargingStation from "../models/station.model.js";
import { JWT_SECRET, JWT_EXPIRES_IN } from "../config/env.js";
import crypto from "crypto";
import nodemailer from "nodemailer";


/**
 * SIGN UP
 */
export const signUp = async (req, res) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const { name, email, phone, password, role } = req.body;

    // 🔴 1. Empty fields
    if (!name || !email || !phone || !password) {
      return res.status(400).json({
        message: "All fields are required"
      });
    }

    // Check: only digits
if (!/^\d+$/.test(phone)) {
  return res.status(400).json({
    message: "Phone number should contain numbers only."
  });
}

// Check: exactly 10 digits
if (phone.length !== 10) {
  return res.status(400).json({
    message: "Phone number must be exactly 10 digits."
  });
}


    // 🔴 3. Email format check (optional but good)
    const emailRegex = /^\S+@\S+\.\S+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        message: "Invalid email format"
      });
    }

    // 🔴 4. Password strength
    if (password.length < 6) {
      return res.status(400).json({
        message: "Password must be at least 6 characters"
      });
    }

    // 🔴 5. Role validation
    const allowedRoles = ["user", "manager"];
    const assignedRole = allowedRoles.includes(role) ? role : "user";

    // 🔴 6. Check existing user
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        message: "User already exists"
      });
    }

    // 🔐 7. Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // 👤 8. Create user
    const newUser = await User.create(
      [{
        name,
        email,
        phone,
        password: hashedPassword,
        role: assignedRole
      }],
      { session }
    );

    // 🔑 9. Generate token
    const token = jwt.sign(
      { id: newUser[0]._id, role: newUser[0].role },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    await session.commitTransaction();
    session.endSession();

    // ✅ SUCCESS RESPONSE
    return res.status(201).json({
      success: true,
      message: "User created successfully",
      token,
      user: newUser[0]
    });

  } catch (error) {
    await session.abortTransaction();
    session.endSession();

    console.error(error); // 👈 IMPORTANT for debugging

    // 🔴 HANDLE MONGOOSE ERRORS
    if (error.code === 11000) {
      return res.status(400).json({
        message: "Email already exists"
      });
    }

    // 🔴 FALLBACK ERROR
    return res.status(500).json({
      message: error.message || "Something went wrong"
    });
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


export const forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: "Email is required" });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Generate a secure 4-digit numeric token
    const resetToken = Math.floor(1000 + Math.random() * 9000).toString(); // 1000-9999

    user.resetPasswordToken = resetToken;
    user.resetPasswordExpires = Date.now() + 15 * 60 * 1000; // 15 minutes
    await user.save();

    // Email setup
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });

    // Send 4-digit token in email
    await transporter.sendMail({
      to: user.email,
      subject: "EVera Password Reset Token",
      html: `
        <p>You requested a password reset.</p>
        <p>Here is your 4-digit password reset token:</p>
        <h2>${resetToken}</h2>
        <p>This token expires in 15 minutes. Use it in the app to reset your password.</p>
      `,
    });

    res.status(200).json({
      success: true,
      message: "Password reset token sent to email",
    });

  } catch (error) {
    next(error);
  }
};

export const resetPassword = async (req, res, next) => {
  try {
    const { email, token, password } = req.body;

    if (!email || !token || !password) {
      return res.status(400).json({
        message: "Email, token and password are required",
      });
    }

    // password rule
    if (!/^(?=.*[A-Z])(?=.*\d).{6,}$/.test(password)) {
      return res.status(400).json({
        message:
          "Password must be at least 6 characters, include 1 capital letter and 1 number",
      });
    }

    const user = await User.findOne({
      email,
      resetPasswordToken: token.toString(),
      resetPasswordExpires: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({
        message: "Invalid or expired reset code",
      });
    }

    user.password = await bcrypt.hash(password, 10);
    user.resetPasswordToken = null;
    user.resetPasswordExpires = null;

    await user.save();

    res.status(200).json({
      success: true,
      message: "Password reset successful",
    });
  } catch (error) {
    next(error);
  }
};
