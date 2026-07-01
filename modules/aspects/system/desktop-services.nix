# Desktop integration services — flatpak, appimage, WebKit/GTK runtime libs.
{ den, ... }:
{
  den.aspects.desktop-services = {
    nixos =
      { pkgs, ... }:
      {
        services.flatpak.enable = true;
        programs.appimage.enable = true;
        environment.systemPackages = with pkgs; [
          webkitgtk_6_0
          webkitgtk_4_1
          gtk4
          libglvnd
          libglibutil
        ];

        xdg.mime.defaultApplications = {
          # Directories
          "inode/directory" = "org.gnome.Nautilus.desktop";

          # PDF
          "application/pdf" = "okularApplication_pdf.desktop";

          # Markdown
          "text/markdown" = "okularApplication_md.desktop";
          "text/x-markdown" = "okularApplication_md.desktop";

          # Writer — plain text, word docs
          "text/plain" = "writer.desktop";
          "text/rtf" = "writer.desktop";
          "application/rtf" = "writer.desktop";
          "application/msword" = "writer.desktop";
          "application/vnd.ms-word" = "writer.desktop";
          "application/vnd.ms-word.document.macroEnabled.12" = "writer.desktop";
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "writer.desktop";
          "application/vnd.openxmlformats-officedocument.wordprocessingml.template" = "writer.desktop";
          "application/vnd.oasis.opendocument.text" = "writer.desktop";

          # Calc — spreadsheets
          "application/vnd.ms-excel" = "calc.desktop";
          "application/vnd.ms-excel.sheet.macroEnabled.12" = "calc.desktop";
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "calc.desktop";
          "application/vnd.openxmlformats-officedocument.spreadsheetml.template" = "calc.desktop";
          "application/vnd.oasis.opendocument.spreadsheet" = "calc.desktop";
          "text/csv" = "calc.desktop";

          # Impress — presentations
          "application/mspowerpoint" = "impress.desktop";
          "application/vnd.ms-powerpoint" = "impress.desktop";
          "application/vnd.ms-powerpoint.presentation.macroEnabled.12" = "impress.desktop";
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "impress.desktop";
          "application/vnd.openxmlformats-officedocument.presentationml.slideshow" = "impress.desktop";
          "application/vnd.oasis.opendocument.presentation" = "impress.desktop";

          # Images — gwenview
          "image/jpeg" = "org.kde.gwenview.desktop";
          "image/png" = "org.kde.gwenview.desktop";
          "image/gif" = "org.kde.gwenview.desktop";
          "image/webp" = "org.kde.gwenview.desktop";
          "image/x-webp" = "org.kde.gwenview.desktop";
          "image/svg+xml" = "org.kde.gwenview.desktop";
          "image/bmp" = "org.kde.gwenview.desktop";
          "image/tiff" = "org.kde.gwenview.desktop";
          "image/avif" = "org.kde.gwenview.desktop";
          "image/heif" = "org.kde.gwenview.desktop";

          # Ebooks — calibre viewer
          "application/epub+zip" = "calibre-ebook-viewer.desktop";
          "application/x-kobo-epub+zip" = "calibre-ebook-viewer.desktop";
          "application/x-mobipocket-ebook" = "calibre-ebook-viewer.desktop";
          "application/x-mobipocket-subscription" = "calibre-ebook-viewer.desktop";
          "application/x-mobi8-ebook" = "calibre-ebook-viewer.desktop";
          "application/x-sony-bbeb" = "calibre-ebook-viewer.desktop";
          "application/ereader" = "calibre-ebook-viewer.desktop";
          "application/oebps-package+xml" = "calibre-ebook-viewer.desktop";
          "application/x-cb7" = "calibre-ebook-viewer.desktop";
          "application/x-cbc" = "calibre-ebook-viewer.desktop";
          "application/x-cbr" = "calibre-ebook-viewer.desktop";
          "application/x-cbz" = "calibre-ebook-viewer.desktop";
          "image/vnd.djvu" = "calibre-ebook-viewer.desktop";
          "text/fb2+xml" = "calibre-ebook-viewer.desktop";
        };
      };
  };
}
