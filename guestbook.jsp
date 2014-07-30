import java.io.*;
import java.sql.*;
import javax.servlet.http.*;
import com.google.appengine.api.utils.SystemProperty;

public class GuestbookServlet extends HttpServlet {
  @Override
  public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
    String url = null;
    try {
      if (SystemProperty.environment.value() ==
          SystemProperty.Environment.Value.Production) {
        // Load the class that provides the new "jdbc:google:mysql://" prefix.
        Class.forName("com.mysql.jdbc.GoogleDriver");
        url = "jdbc:google:mysql://your-project-id:your-instance-name/guestbook?user=root";
      } else {
        // Local MySQL instance to use during development.
        Class.forName("com.mysql.jdbc.Driver");
        url = "jdbc:mysql://127.0.0.1:3306/guestbook?user=root";

        // Alternatively, connect to a Google Cloud SQL instance using:
        // jdbc:mysql://ip-address-of-google-cloud-sql-instance:3306/guestbook?user=root
      }
    } catch (Exception e) {
      e.printStackTrace();
      return;
    }

    PrintWriter out = resp.getWriter();
    try {
      Connection conn = DriverManager.getConnection(url);
      try {
        String fname = req.getParameter("fname");
        String content = req.getParameter("content");
        if (fname == "" || content == "") {
          out.println(
              "<html><head></head><body>You are missing either a message or a name! Try again! " +
              "Redirecting in 3 seconds...</body></html>");
        } else {
          String statement = "INSERT INTO entries (guestName, content) VALUES( ? , ? )";
          PreparedStatement stmt = conn.prepareStatement(statement);
          stmt.setString(1, fname);
          stmt.setString(2, content);
          int success = 2;
          success = stmt.executeUpdate();
          if (success == 1) {
            out.println(
                "<html><head></head><body>Success! Redirecting in 3 seconds...</body></html>");
          } else if (success == 0) {
            out.println(
                "<html><head></head><body>Failure! Please try again! " +
                "Redirecting in 3 seconds...</body></html>");
          }
        }
      } finally {
        conn.close();
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    resp.setHeader("Refresh", "3; url=/guestbook.jsp");
  }
}
