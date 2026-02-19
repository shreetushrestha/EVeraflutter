import Station from "../models/station.model.js";

/**
 * GET ALL STATIONS
 */
export const getAllStations = async (req, res) => {
  try {
    const stations = await Station.find();
    res.status(200).json(stations);
  } catch (error) {
    res.status(500).json({
      message: "Server Error",
      error: error.message
    });
  }
};

/**
 * CREATE STATION (ADMIN)
 */
export const createStation = async (req, res) => {
  try {
    if (!["admin", "manager"].includes(req.user.role)) {
      return res.status(403).json({
        message: "Only admin or manager can create stations"
      });
    }

    let {
      name,
      city,
      province,
      address,
      telephone,
      latitude,
      longitude,
      plugs,
      totalSlots,
      availableSlots,
      amenities,
      images,
      manager
    } = req.body;

    // Slot validation
    if (availableSlots > totalSlots) {
      return res.status(400).json({
        message: "Available slots cannot be greater than total slots"
      });
    }

    // 🧠 Manager can only create station for themselves
    const assignedManager =
      req.user.role === "manager" ? req.user.id : manager;

    // ✅ Normalize plugs array
    if (!Array.isArray(plugs)) {
      plugs = []; // default empty array
    }

    plugs = plugs.map(p => ({
      plug: p.plug || "",
      power: p.power || "",
      type: p.type || ""
    }));

    const newStation = new Station({
      name,
      city,
      province,
      address,
      telephone,
      latitude,
      longitude,
      plugs,
      totalSlots,
      availableSlots,
      amenities,
      images,
      manager: assignedManager
    });

    await newStation.save();

    res.status(201).json({
      message: "Station created successfully",
      station: newStation
    });

  } catch (error) {
    res.status(500).json({
      message: "Server Error",
      error: error.message
    });
  }
};



/**
 * GET STATION BY ID
 */
export const getStationById = async (req, res) => {
  try {
    const station = await Station.findById(req.params.id);

    if (!station) {
      return res.status(404).json({ message: "Station not found" });
    }

    res.status(200).json(station);
  } catch (error) {
    res.status(500).json({
      message: "Server Error",
      error: error.message
    });
  }
};

/**
 * UPDATE STATION (ADMIN / MANAGER)
 */
export const updateStation = async (req, res) => {
  try {
    const stationId = req.params.id;
    const updates = req.body;

    // Slot validation if slots are updated
    if (
      updates.totalSlots !== undefined &&
      updates.availableSlots !== undefined &&
      updates.availableSlots > updates.totalSlots
    ) {
      return res.status(400).json({
        message: "Available slots cannot exceed total slots"
      });
    }

    const updatedStation = await Station.findByIdAndUpdate(
      stationId,
      updates,
      { new: true, runValidators: true }
    );

    if (!updatedStation) {
      return res.status(404).json({ message: "Station not found" });
    }

    res.status(200).json({
      message: "Station updated successfully",
      station: updatedStation
    });
  } catch (error) {
    res.status(500).json({
      message: "Server Error",
      error: error.message
    });
  }
};

/**
 * DELETE STATION (ADMIN)
 */
export const deleteStation = async (req, res) => {
  try {
    const station = await Station.findByIdAndDelete(req.params.id);

    if (!station) {
      return res.status(404).json({ message: "Station not found" });
    }

    res.status(200).json({ message: "Station deleted successfully" });
  } catch (error) {
    res.status(500).json({
      message: "Server Error",
      error: error.message
    });
  }
};

export const getMyStations = async (req, res, next) => {
  try {
    console.log("Fetching stations for user:", req.user);
    if (req.user.role !== "manager") {
      return res.status(403).json({ message: "Access denied" });
    }

    const stations = await Station.find({
      manager: req.user.id
    });

    res.status(200).json({
      success: true,
      data: stations
    });
  } catch (error) {
    next(error);
  }
};


export const toggleOperational = async (req, res) => {
  try {
    const { stationId, isOperational } = req.body;

    const station = await Station.findById(stationId);

    if (!station) {
      return res.status(404).json({ message: "Station not found" });
    }

    if (
      req.user.role !== "admin" &&
      station.manager.toString() !== req.user.id
    ) {
      return res.status(403).json({ message: "Unauthorized" });
    }

    station.isOperational = isOperational;
    await station.save();

    res.status(200).json({
      message: "Operational status updated",
      station
    });

  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};

