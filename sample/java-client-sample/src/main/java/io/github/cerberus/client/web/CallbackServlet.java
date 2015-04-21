package io.github.cerberus.client.web;

import io.github.cerberus.client.AuthenticationApiService;
import io.github.cerberus.client.ServiceConfiguration;
import io.github.cerberus.client.User;

import java.io.IOException;
import java.net.URL;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.scribe.model.Token;

@WebServlet(name="CallbackServlet", urlPatterns="/Callback")
public class CallbackServlet extends HttpServlet {

  private final ServiceConfiguration config = ServiceConfiguration.getInstance();

  /**
   * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
   *
   * @param request servlet request
   * @param response servlet response
   * @throws ServletException if a servlet-specific error occurs
   * @throws IOException if an I/O error occurs
   */
  protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String code = request.getParameter("code");
    String referer = request.getHeader("Referer");
    URL refererURL = new URL(referer);
    URL callbackURL = new URL(refererURL.getProtocol(), refererURL.getHost(), refererURL.getPort(), request.getContextPath() + config.getCallback());
    AuthenticationApiService service =
        AuthenticationApiService.getInstance(config.getServiceUrl(), config.getClientId(), config.getClientSecret(), callbackURL.toString());
    Token accessToken = service.getTokenByAuthorizationCode(code, null);
    User userByToken = service.getUserByToken(accessToken);
    String acessTokenStr = accessToken.getToken();
    String userFullName = userByToken.fullName;
    String userName = userByToken.username;
    String userEmail = userByToken.email;
    request.setAttribute("access_code", code);
    request.setAttribute("access_token", acessTokenStr);
    request.setAttribute("user_full_name", userFullName);
    request.setAttribute("user_login", userName);
    request.setAttribute("user_email", userEmail);
    request.getRequestDispatcher("Callback.jsp").forward(request, response);
  }

  // <editor-fold defaultstate="collapsed"
  // desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
  /**
   * Handles the HTTP <code>GET</code> method.
   *
   * @param request servlet request
   * @param response servlet response
   * @throws ServletException if a servlet-specific error occurs
   * @throws IOException if an I/O error occurs
   */
  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    processRequest(request, response);
  }

  /**
   * Handles the HTTP <code>POST</code> method.
   *
   * @param request servlet request
   * @param response servlet response
   * @throws ServletException if a servlet-specific error occurs
   * @throws IOException if an I/O error occurs
   */
  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    processRequest(request, response);
  }

  /**
   * Returns a short description of the servlet.
   *
   * @return a String containing servlet description
   */
  @Override
  public String getServletInfo() {
    return "Short description";
  }// </editor-fold>

}
