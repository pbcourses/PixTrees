//
//  Forest.swift
//  PixTrees
//
//  Created by Matteo Piombo on 08/01/16.
//  Copyright © 2016 Matteo Piombo. All rights reserved.
//

import Foundation

/// Could be used for future generalizations.
/// Possible use is increased Forest type safety
public protocol ForestTree {
    var location: ForestLocation { get }
}

/// Stores a location in a forest.
public struct ForestLocation {
    let x: Int
    let y: Int
}

// Make ForestLocation Equatable
public func ==(lhs: ForestLocation, rhs: ForestLocation) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

extension ForestLocation: Equatable {}

//MARK: - Forest

/// Class implementing the Forest logic
///
public final class Forest {
    /// The Forest ID
    let forestID: String
    
    /// The x range for the forest field. Starting from 0 with xLenght count
    let forestXRange: Range<Int>
    
    /// The y range for the forest field. Starting from 0 with yLenght count
    let forestYRange: Range<Int>
    
    /// Stores y coordinate for the tree at index x coordinate, enmpty if no tree is present at x coordinate.
    private var xs: Array<Int?>
    
    /// Stores x coordinate for the tree at index y coordinate, enmpty if no tree is present at y coordinate.
    /// Used to optimize valid tree location query.
    private var ys: Array<Int?>
    
    /// Keeps trak of how many trees are in the forest.
    /// - Complexity: O(1)
    private(set) var count: Int
    
    /// Returns all trees locations in the forest
    /// **Locations are sorted by x ascending**
    /// - Complexity: O(n) where n is x forest length
    var treeLocations: Array<ForestLocation> {
        var locations: Array<ForestLocation> = []
        for x in xs.indices {
            if let y = xs[x] {
                locations.append(ForestLocation(x: x, y: y))
            }
        }
        return locations
    }
    
    // Consider a failing initializer in case x or y length are 0 or negative, or empty id
    init(id: String, xLength: Int, yLength: Int) {
        
        self.forestID = id
        self.forestXRange = 0..<xLength
        self.forestYRange = 0..<yLength
        
        xs = Array<Int?>(count: xLength, repeatedValue: nil)
        ys = Array<Int?>(count: yLength, repeatedValue: nil)
        count = 0
        
    }
    
    /// Mark the location in the forest as occupied.
    /// - Parameter location: destination coordinate of the tree in the forest.
    /// - Returns: true if location was added
    func addTree(location: ForestLocation) -> Bool {
        
        guard locationIsInsideForest(location) else { return false }    // Location is ouside forest area
        
        guard !containsTree(location) else { return false }             // Location should be free
        
        xs[location.x] = location.y
        ys[location.y] = location.x
        count += 1
        return true
    }
    
    /// Mark the location in the forest as free.
    /// - Parameter location: coordinate of the tree in the forest.
    /// - Returns: true a valid tree was actually removed
    func removeTree(location: ForestLocation) -> Bool {
        guard locationIsInsideForest(location) else { return false }    // Location is ouside forest area
        
        guard containsTree(location) else { return false } // No tree present in location
        
        // Empty arrays at given coordinates
        xs[location.x] = nil
        ys[location.y] = nil
        
        // Decrease tree count
        count -= 1
        
        return true
    }
    
    
    /// Removes all trees in the rectangle defined by the two vertex locations.
    /// The two vertexes should also contain a tree.
    ///
    /// - Parameter firstVertex: location of the first vertex in the forest. Should contain a tree.
    /// - Parameter secondVertex: location of the second vertex in the forest. Should contain a tree.
    ///
    /// - Returns: number of trees removed. `nil` if the area defined by the vertexes is not valid.
    func removeBetween(firstVertex first: ForestLocation, secondVertex second: ForestLocation) -> Int? {
        
        guard locationIsInsideForest(first) && locationIsInsideForest(second) else { return nil }   // Area should be inside forest
        guard containsTree(first) && containsTree(second) else { return nil }                       // Vertexes should contain a tree
        
        let xRange = min(first.x, second.x)...max(first.x, second.y)
        let yRange = min(first.y, second.y)...max(first.y, second.y)
        
        
        var removed = 0
        
        for x in xRange {
            
            for y in yRange {
                
                let location = ForestLocation(x: x, y: y)
                
                if removeTree(location) {
                    removed += 1
                }
            }
        }
        
        return removed
    }
    
    //MARK: - Search algorithm
    
    /// Finds all possible rectangles in the forest containing the given number of trees.
    /// Rectangles will have trees at their vertexes.
    ///
    /// - Parameter k: number of trees contained in the returned rectangles
    /// - Returns: an array of tuples defining the two vertexes of rectangles holding the condition.
    func rectanglesContaining(k: Int) -> Array<(ForestLocation, ForestLocation)> {
        guard k > 1 else { return [] }          // At least 2 trees are needed to form a rectangle
        guard k <= count else { return [] }     // Not enoght trees in the forest
        
        // Find all possible rectangles
        var forestAreas: Array<(ForestLocation, ForestLocation)> = []
        let allTreeXs = treeLocations
        
        for (idx, firstVertex) in allTreeXs.enumerate() {
            
            for secondVertex in allTreeXs[idx.successor()..<allTreeXs.endIndex] {
                // X range between the two vertexes
                let vertexesXRange = firstVertex.x...secondVertex.x
                
                // A range having length less than k cannot contain k trees
                if vertexesXRange.count < k {
                    continue
                }
                
                // Count trees inside the area defined by the two vertexes x range
                // If it is k then the two vertexes defines a solution.
                if numberOfTreesInAreaByXRange(vertexesXRange) == k {

                    forestAreas.append((firstVertex, secondVertex))
                }
            }
        }
        return forestAreas
    }
    
    /// Checks if a location is inside the forest area
    ///
    /// - Parameter location: The location to check.
    /// - Returns: true if location is inside the forest area.
    private func locationIsInsideForest(location: ForestLocation) -> Bool {
        return forestXRange.contains(location.x) && forestYRange.contains(location.y)
    }
    
    
    /// Check if there is a tree at location
    /// - Parameter location: The location in the forest to look at.
    /// - Returns: true if there is a tree at location.
    /// - Warning: Internal use only. **Does not check for location inside forest area**
    private func containsTree(location: ForestLocation) -> Bool {
        
        // the location x coordinate should contain an y coordinate which is equal to the location y coordinate.
        guard let y = xs[location.x]  where y == location.y else { return false }
        
        return true
    }
    
    /// Search for the number of trees in a possible rectangle defined just by its x coordinate range.
    /// If there are trees at the start and end of the x range, they will define a valid rectangle.
    ///
    /// - Parameter xRange: The range of xs to search.
    /// - Returns: number of trees inside the valid area defined by the given x range. 
    ///   `nil` if the range does not define a valid area having trees at its vertexes.
    ///
    /// - Complexity: O(n) where n is the x range length.
    private func numberOfTreesInAreaByXRange(xRange: Range<Int>) -> Int? {
        
        // Range should be at least of length 2
        guard xRange.count > 1 else { return nil }
        
        // Range should end inside the forest
        guard xRange.endIndex <= forestXRange.endIndex else { return nil }

        // Make sure first and last xs actualy contains a tree
        guard let firstTreeY = xs[xRange.startIndex],
            let lastTreeY = xs[xRange.endIndex.predecessor()] else {
                return nil
        }
        
        let yRange = min(firstTreeY, lastTreeY)...max(firstTreeY, lastTreeY) // rectangle y range
        var treeCount = 0
        
        for x in xRange {
            if let y = xs[x] where yRange.contains(y) {
                treeCount += 1
            }
        }
        return treeCount
    }
}
