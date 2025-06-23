import 'package:cloudinary_sdk/cloudinary_sdk.dart';

class MediaRepository {
  late Cloudinary cloudinary;

  MediaRepository() {
    cloudinary = Cloudinary.full(
      apiKey: '468988846658246',
      apiSecret: 'j4CbG195NYgWTbpAVCBENlTDAUg',
      cloudName: 'dpw7heky8',
    );
  }

  Future<CloudinaryResponse> uploadImage(String path) {
    return cloudinary.uploadResource(
      CloudinaryUploadResource(
        filePath: path,
        resourceType: CloudinaryResourceType.image,
      ),
    );
  }

  Future<CloudinaryResponse> uploadPdf(String path) {
    return cloudinary.uploadResource(
      CloudinaryUploadResource(
        filePath: path,
        resourceType: CloudinaryResourceType.raw, // <--- Key change here
        // You could also use CloudinaryResourceType.auto if you want Cloudinary
        // to automatically detect the file type (image, video, raw, etc.)
        // resourceType: CloudinaryResourceType.auto,
        // You might also want to specify a folder for PDFs
        folder: "resumes_pdfs", // Optional: Organize your uploads
      ),
    );
  }
}
