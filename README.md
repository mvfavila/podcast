# Podcast Client Mobile App

## Overview
This is a mobile app built using Flutter that allows users to search for, subscribe to, and manage their favorite podcasts. The app also includes features such as episode auto-downloads, playlist management, and custom notifications for new episodes. 

### Key Features
1. **User Authentication (via Gmail)**:
   - Users can sign up or sign in using their Gmail account via Google OAuth 2.0. Future iterations will include Facebook and email/password login.
   
2. **Podcast Search (Spotify API)**:
   - Users can search for podcasts using the Spotify API. In the future, additional podcast directories may be added.

3. **Subscription Management**:
   - Users can subscribe to podcasts, and subscriptions are stored in the cloud via Firebase.
   - Automatically receive notifications when a new episode is available for subscribed podcasts.

4. **Episode Playlist**:
   - The app features a single, unified playlist where users can add podcast episodes manually or via filters.

5. **Automatic Download & Storage Management**:
   - Users can set custom keywords to automatically download episodes or add them to the playlist.
   - The app automatically manages storage by deleting episodes that have been played.

6. **Notifications**:
   - Users can choose to receive notifications when new episodes of subscribed podcasts are released.
   
7. **Custom Episode Filtering**:
   - Episodes can be filtered by custom keywords, which trigger automatic downloads or additions to the playlist.

## Tech Stack

### Frontend:
- **Flutter**: Cross-platform mobile app development for iOS and Android.

### Backend:
- **Firebase**: 
  - **Firebase Authentication**: For managing user sign-ins and sessions.
  - **Firebase Firestore
