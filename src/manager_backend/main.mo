/** 
title:  Zreg Asset Manager
aim: An ecosystem of registered users to safely store and manage their assets on the blockchain
**/

import Principal "mo:base/Principal";
import Array "mo:base/Array";

actor Manager {

    type User = {
      name: Text;
      address: Principal; //id may just be the wallet address
      password: Text;
    };

    type Asset = {
      name: Text;
      owner: Principal;
      value: Nat;
      price: Float;
    };

    var assets: [Asset] = [];
    var users: [User] = [];
    var loggedin : Bool = false;

    // Bind user to address
    public func registerUser(name: Text, passwd: Text) : async Text{
      let caller = Principal.fromActor(Manager);
      let user : User = { name; address = caller; password = passwd};
      users := Array.append(users, [user]);
      return "User " # name # " Successfully registered. Welcome to Zreg Asset Manager\nPlease login"
    };

    // Login
    public func login (name: Text, passwd: Text) : async Text{
      if (loggedin == true) {
        return "You are already loggedin";
      }
      else {
        for (user in users.vals()) {
          if (user.name == name and user.password == passwd) {
            loggedin := true;
            return ("Welcome back " # name);
        }
      }
    };
    return "Invalid username or password";
    };


    // Register a new asset
    public func registerAsset(name: Text, value: Nat, price: Float) : async Text {
      if (loggedin == true) {
        let caller = Principal.fromActor(Manager);  // Capture the caller's Principal (identity)
        let asset: Asset = { name; owner = caller; value; price};
        assets := Array.append(assets, [asset]);
        return "Asset " # asset.name # "  registered successfully!";
      }
      else {
        return "Error! You must be logged in to carry out this operation";
      }
    };


    // Transfer an asset to another user
    public func transferAsset(assetName: Text, newOwner: Principal) : async Text {
      if (loggedin == true) {
        let caller = Principal.fromActor(Manager);  // Capture the caller's identity

        var found: Bool = false;
        assets := Array.map<Asset, Asset>(assets, func(asset) {
            if (asset.name == assetName and asset.owner == caller) {
                found := true;
                return { name = asset.name; owner = newOwner; value = asset.value; price=asset.price };
            } else {
                return asset;
            }
        });

        // Display Message
        if (found) {
            return "Asset transferred!";
        } else {
            return "Error occured: Asset unavailable for this user!";
        };
      }
      else {
        return "Error! You must be logged in to carry out this operation";
      }
    };

    // Retrieve details of an asset
    public query func getAsset(assetName: Text) : async ?Asset {
        return Array.find<Asset>(assets, func(asset) {
            asset.name == assetName
        });
    };

    // Get all assets owned by a specific user
    public query func getAssetsByOwner(owner: Principal) : async [Asset] {
        return Array.filter<Asset>(assets, func(asset) {
            asset.owner == owner
        });
    };

    type DispUser = {
      name: Text;
      address: Principal;
    };

    public query func getUsers() : async [DispUser]{
      var result : [DispUser] = [];
      for (user in users.vals()) {
        let res : DispUser = {name = user.name; address = user.address};
        result := Array.append<DispUser>(result, [res]);
      };
      return result;
    }
};
