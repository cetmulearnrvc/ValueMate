import NearbyLandValue from "../models/nearbyLandValue_model.js";

function haversineDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Radius of the Earth in kilometers
    const dLat = (lat2 - lat1) * (Math.PI / 180);
    const dLon = (lon2 - lon1) * (Math.PI / 180);
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * (Math.PI / 180)) * Math.cos(lat2 * (Math.PI / 180)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c; // Distance in km
}



export const saveToNearby = async (req, res) => {
    // console.log("Request to save/update to nearby collection:", req.body);
    try {
        const { refNo, latitude, longitude, landValue, nameOfOwner, bankName } = req.body;

        if (!refNo) {
            return res.status(400).json({ message: "Reference number (refNo) is required." });
        }

        // --- THIS IS THE KEY CHANGE ---
        // We wrap the data we want to change inside a `$set` operator.
        const updatePayload = {
            $set: {
                latitude,
                longitude,
                landValue,
                nameOfOwner,
                bankName,
                // We don't need to set refNo here, as it's our key and won't change.
            }
        };

        const updatedEntry = await NearbyLandValue.findOneAndUpdate(
            { refNo: refNo },      // The condition to find the document
            updatePayload,         // The update payload with the $set operator
            { 
              new: true,           // Return the updated document
              upsert: true         // Create if it doesn't exist
            }
        );

        // console.log("Successfully upserted document:", updatedEntry);
        res.status(200).json({ 
            message: "Successfully saved or updated nearby data.",
            data: updatedEntry 
        });

    } catch (error) {
        console.error("Error in saveToNearby controller:", error);
        res.status(500).json({ message: "Server error while saving/updating nearby data." });
    }
};

export const getNearby = async (req, res) => {
    const SEARCH_RADIUS_KM = 15;
    // console.log("Received request to get nearby properties:", req.body);

    try {
        const { latitude, longitude } = req.body;
        const lat1 = parseFloat(latitude);
        const lon1 = parseFloat(longitude);

        if (isNaN(lat1) || isNaN(lon1)) {
            return res.status(400).json({ message: "Invalid latitude or longitude format." });
        }

        const responseData = [];
        const cursor = NearbyLandValue.find().cursor();

        for (let doc = await cursor.next(); doc != null; doc = await cursor.next()) {
            if (doc.latitude && doc.longitude) {
                const lat2 = parseFloat(doc.latitude);
                const lon2 = parseFloat(doc.longitude);

                if (!isNaN(lat2) && !isNaN(lon2)) {
                    const distance = haversineDistance(lat1, lon1, lat2, lon2);
                    if (distance <= SEARCH_RADIUS_KM) {
                        // --- THIS IS THE KEY FIX ---
                        // Use .toObject() to get all fields from the Mongoose document
                        const propertyData = doc.toObject(); 
                        propertyData.distance = distance;
                        responseData.push(propertyData);
                    }
                }
            }
        }
        
        responseData.sort((a, b) => a.distance - b.distance);
        
        // console.log("Sending back nearby data:", responseData); // Add this log to see what is being sent
        res.status(200).json(responseData);

    } catch (error) {
        console.error("Error in getNearby controller:", error);
        res.status(500).json({ message: "Server error while fetching nearby properties." });
    }
};