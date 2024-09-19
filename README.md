# Info Form Flutter Application

This Flutter application allows users to fill out a form with their personal information, including name, age, email, gender, employment status, date of birth, and address. The data is saved to a server, and users can update or delete their existing information, which is also saved as a PDF.

## Features

- User can enter their personal details (name, age, email, gender, employment status, date of birth, and address).
- Form validation to ensure correct input.
- Users can upload their details and generate a PDF.
- Users can update their existing information and replace the PDF.
- Users can delete their stored information and associated PDF from the server.
- Integration with Firebase for data storage and SFTP server for PDF uploads.

## Screenshots

<img src="https://github.com/user-attachments/assets/11087a17-098b-4ed3-97e0-ac566abd8a51" alt="description" width="300"/>
<img src="https://github.com/user-attachments/assets/79a70038-2eaf-4559-ab35-576c1e7d4b0e" alt="description" width="700"/>
<img src="https://github.com/user-attachments/assets/22e39160-9bea-4e7c-a476-7f70595d8ea1" alt="description" width="600"/>


<!-- Include screenshots of the app interface -->

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/tejas-gaikwad/bb_task_2.git
   cd bb_task_2


Install the dependencies:
flutter pub get

Run the application:
flutter run

flutter: Flutter framework for building cross-platform mobile apps.
Custom widgets for text fields and form elements.
External services (Firebase, SFTP) to upload and store data.


Usage
On app launch, if the user has already submitted data, the form will load with their previously submitted details.
Users can fill in the form and submit their details by pressing the Save button. If the form is already populated, users can update their details.
The data is saved as a PDF on the server, and the user can update or delete the document.
All actions (submit, update, delete) are processed via backend services integrated with Firebase and SFTP.

Core Functionality
Data Submission: Upon successful form validation, the data is sent to a server where a PDF is generated, stored, and uploaded.
Data Retrieval: On app start, the previously saved data is loaded into the form fields, allowing users to update or delete their information.
PDF Generation: A user’s details are formatted into a PDF file using a third-party service, and uploaded to both Firebase and an SFTP server.
Backend Integration
The app integrates with external services for data management:

Firebase: Used to store the user's data and the generated PDF.
SFTP Server: The PDF is uploaded to an SFTP server.
Custom Services: The project uses a custom service layer (lib/services/common_services.dart) to handle all backend communication.







