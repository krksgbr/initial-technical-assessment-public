# Marvel Character Feed - Technical Assessment

## Overview

This repository contains a SwiftUI project designed to present a feed of Marvel characters. Each element in the feed represents a Marvel character, followed by a list of the comics in which each character appears. The purpose of this project is to assess the candidate's ability to identify and document performance issues within the codebase.

## Project Structure

The project is structured as follows:

- **IGListSwiftUI/Network**: A simple network manager to fetch data from Marvel's API. You will need to provide an API public key and an API private key. The process is described [here](https://developer.marvel.com/documentation/getting_started).
- **IGListSwiftUI/UI**: Generic elements to assist with the UI.
- **IGListSwiftUI/Feed**: SwiftUI components to display the character feed.

## Assessment Goals

The primary objectives of this technical assessment are as follows:

1. **Identify Performance Issues:** Evaluate the existing codebase for any performance bottlenecks, inefficient algorithms, or resource-heavy operations that may impact the app's performance.

2. **Document Issues:** Thoroughly document any performance issues discovered during the assessment. Provide detailed insights into the specific areas of concern, accompanied by relevant data and information about the diagnostic tools used to identify these issues.

3. **Recommendations:** Suggest possible solutions or improvements to address the identified performance issues. This may include code optimizations, algorithm changes, or architecture adjustments.

## Getting Started

To begin the assessment, follow these steps:

1. Clone the repository:

    ```bash
    git clone https://github.com/your-username/marvel-character-feed.git
    ```

2. Open the project in Xcode:

    ```bash
    open Initial Technical Assessment.xcodeproj
    ```

3. Set your [API Keys](https://developer.marvel.com/documentation/getting_started) in the Constants class.

4. Explore the codebase and run the project to observe its behavior.

## Assessment Guidelines

We are seeking a **performance analysis** report rather than a PR review. Therefore, during the assessment, concentrate on the following aspects:

- **User Interface (UI) Performance:** Evaluate the smoothness and responsiveness of the user interface, especially when scrolling through the character feed and navigating the comics.

- **Network Requests:** Examine the efficiency of network requests made to the Marvel Comics API. Identify any unnecessary or redundant requests that may impact the app's responsiveness.

- **Resource Management:** Assess how the app manages resources, including memory usage and potential memory leaks. Look for areas where resource cleanup or optimization may be necessary.

## Documentation and Submission

Document your findings and send them to ios-hiring@lapse.app. Provide a clear and concise summary of identified performance issues, their impact, and recommended solutions. Feel free to use code snippets, screenshots, or any relevant information to support your observations.

Thank you for participating in this technical assessment! If you have any questions, feel free to reach out to ios-hiring@lapse.app.
