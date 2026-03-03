import mongoose from "mongoose";
import User from "../models/user.models.js";
import Station from "../models/station.model.js";

const { Types } = mongoose;
const isValidObjectId = (id) => Types.ObjectId.isValid(id);

// Add a station to the user's favorites list
export const addFavorite = async (req, res, next) => {
  try {
    const userId = req.user?._id || req.user?.id;
    const { stationId } = req.params;

    if (!stationId) {
      return res.status(400).json({ message: "Station ID is required" });
    }

    if (!isValidObjectId(stationId)) {
      return res.status(400).json({ message: "Invalid station ID" });
    }

    if (!userId || !isValidObjectId(userId)) {
      return res.status(400).json({ message: "Invalid user" });
    }

    const station = await Station.findById(stationId);
    if (!station) {
      return res.status(404).json({ message: "Station not found" });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    user.favorites = user.favorites || [];

    if (user.favorites.some((fav) => fav.toString() === stationId)) {
      return res.status(400).json({ message: "Station already in favorites" });
    }

    user.favorites.push(station._id);
    await user.save();

    const populated = await User.findById(userId).populate("favorites");
    res.status(200).json({
      message: "Station added to favorites",
      favorites: populated.favorites,
    });
  } catch (err) {
    console.error("addFavorite error", err);
    next(err);
  }
};

// Remove a station from favorites
export const removeFavorite = async (req, res, next) => {
  try {
    const userId = req.user?._id || req.user?.id;
    const { stationId } = req.params;

    if (!stationId) {
      return res.status(400).json({ message: "Station ID is required" });
    }
    if (!isValidObjectId(stationId)) {
      return res.status(400).json({ message: "Invalid station ID" });
    }
    if (!userId || !isValidObjectId(userId)) {
      return res.status(400).json({ message: "Invalid user" });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    user.favorites = (user.favorites || []).filter(
      (fav) => fav.toString() !== stationId
    );
    await user.save();

    const populated = await User.findById(userId).populate("favorites");
    res.status(200).json({
      message: "Station removed from favorites",
      favorites: populated.favorites,
    });
  } catch (err) {
    console.error("removeFavorite error", err);
    next(err);
  }
};

// Get favorites for a user (defaults to authenticated user)
export const getFavorites = async (req, res, next) => {
  try {
    // allow query param for admin to view other users
    const requestedUserId = req.query.userId || (req.user && req.user.id);
    if (!requestedUserId) {
      return res.status(400).json({ message: "User ID is required" });
    }

    if (!isValidObjectId(requestedUserId)) {
      return res.status(400).json({ message: "Invalid user ID" });
    }

    // if user requests someone else's favorites, only admin allowed
    if (
      req.user &&
      req.user.id !== requestedUserId &&
      req.user.role !== "admin"
    ) {
      return res.status(403).json({ message: "Access denied" });
    }

    const user = await User.findById(requestedUserId).populate("favorites");
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json({ favorites: user.favorites });
  } catch (err) {
    console.error("getFavorites error", err);
    next(err);
  }
};
