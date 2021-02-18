import java.io.BufferedReader;
import java.io.FileReader;
import java.sql.*;
import java.util.Scanner;

public class BookStore {
    // Reset
    public static final String RESET = "\033[0m";  // Text Reset
    // Regular Colors
    public static final String YELLOW = "\033[0;33m";  // YELLOW
    public static final String BLUE = "\033[0;34m";    // BLUE
    // Bold
    public static final String RED_BOLD = "\033[1;31m";    // RED
    public static final String GREEN_BOLD = "\033[1;32m";  // GREEN
    public static final String PURPLE_BOLD = "\033[1;35m"; // PURPLE
    public static final String WHITE_BOLD = "\033[1;37m";  // WHITE

    private int loginID;
    private String role;
    Connection con;

    public void startConnection() {
        Scanner scanner = new Scanner(System.in);
        String username;
        String password;
        System.out.println(GREEN_BOLD + "Please wait ..." + RESET);
        try {
            con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/sys", "root", "root");
            ScriptRunner runner = new ScriptRunner(con, false, true);
            runner.runScript(new BufferedReader(new FileReader("book_store_creation.sql")));
            System.out.println(WHITE_BOLD + "successfully refreshed the schema!!" + RESET);
            System.out.println(PURPLE_BOLD + "please enter you'r username:    " + RESET);
            username = scanner.nextLine();
            System.out.println(PURPLE_BOLD + "please enter you'r password:    " + RESET);
            password = scanner.nextLine();
            CallableStatement cStmt = con.prepareCall("{? = call make_login(? , ?)}");
            cStmt.registerOutParameter(1, Types.INTEGER);
            cStmt.setString(2, username);
            cStmt.setString(3, password);
            cStmt.execute();
            int output = cStmt.getInt(1);
            cStmt.close();
            loginID = output;
        } catch (Exception e) {
            System.out.println(RED_BOLD + e + RESET);
            con = null;
            loginID = -1;
        }
    }

    public void getRole() {
        try {
            CallableStatement cStmt = con.prepareCall("{? = call get_role(?)}");
            cStmt.registerOutParameter(1, Types.VARCHAR);
            cStmt.setInt(2, loginID);
            cStmt.execute();
            role = cStmt.getString(1);
            cStmt.close();
        } catch (Exception e) {
            System.out.println(RED_BOLD + e + RESET);
        }
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        boolean work = true;
        BookStore bs = new BookStore();
        bs.startConnection();
        if (bs.con == null) {
            System.out.println(RED_BOLD + "couldn't make the connection" + RESET);
            return;
        }
        bs.getRole();
        String input;
        /* code */
        System.out.println(WHITE_BOLD + "Hi" + RESET);
        System.out.println(WHITE_BOLD + "you are connected!" + RESET);
        if (bs.role.equals("res") || bs.role.equals("man")) {
            while (work) {
                System.out.println(WHITE_BOLD + "what can I do for you?" + RESET);
                System.out.println(WHITE_BOLD + "1.add book to warehouse" + RESET);
                System.out.println(WHITE_BOLD + "2.add book in book list" + RESET);
                System.out.println(WHITE_BOLD + "3.add publication (only manager)" + RESET);
                System.out.println(WHITE_BOLD + "4.show messages" + RESET);
                System.out.println(WHITE_BOLD + "5.see delays in return" + RESET);
                System.out.println(WHITE_BOLD + "6.see borrow history" + RESET);
                System.out.println(WHITE_BOLD + "7.search a user" + RESET);
                System.out.println(WHITE_BOLD + "8.users history" + RESET);
                System.out.println(WHITE_BOLD + "9.add an account" + RESET);
                System.out.println(WHITE_BOLD + "10.delete an account (only manager)" + RESET);
                System.out.println(WHITE_BOLD + "0.exit" + RESET);
                input = scanner.nextLine();
                switch (input) {
                    case "1":
                        try {
                            System.out.println(WHITE_BOLD + "please enter the book id:" + RESET);
                            int book_id = Integer.parseInt(scanner.nextLine());
                            System.out.println(WHITE_BOLD + "please enter the volume:" + RESET);
                            int volume = Integer.parseInt(scanner.nextLine());
                            System.out.println(WHITE_BOLD + "please enter the begin of version:" + RESET);
                            int begin_v = Integer.parseInt(scanner.nextLine());
                            System.out.println(WHITE_BOLD + "please enter the end of version:" + RESET);
                            int end_v = Integer.parseInt(scanner.nextLine());
                            PreparedStatement pStatement = bs.con.prepareStatement("CALL res_proc_add_book (?,?,?,?,?)");
                            pStatement.setInt(1, bs.loginID);
                            pStatement.setInt(2, book_id);
                            pStatement.setInt(3, volume);
                            pStatement.setInt(4, begin_v);
                            pStatement.setInt(5, end_v);
                            ResultSet rSet = pStatement.executeQuery();
                            if (rSet.next())
                                System.out.println(WHITE_BOLD + rSet.getString(1) + RESET);
                            rSet.close();
                            pStatement.close();
                        } catch (Exception e) {
                            System.out.println(RED_BOLD + e + RESET);
                        }
                        break;
                    case "2":
                        try {
                            System.out.println(WHITE_BOLD + "please fill this form:" + RESET);
                            System.out.print(WHITE_BOLD + "book id:" + RESET);
                            int book_id = Integer.parseInt(scanner.nextLine());
                            System.out.print(WHITE_BOLD + "volume:" + RESET);
                            int volume = Integer.parseInt(scanner.nextLine());
                            System.out.print(WHITE_BOLD + "title:" + RESET);
                            String title = scanner.nextLine();
                            System.out.print(WHITE_BOLD + "category:" + RESET);
                            String category = scanner.nextLine();
                            System.out.print(WHITE_BOLD + "publication:" + RESET);
                            String publication = scanner.nextLine();
                            System.out.print(WHITE_BOLD + "publication date (in format YYYY-MM-DD):" + RESET);
                            String publication_date = scanner.nextLine();
                            System.out.print(WHITE_BOLD + "pages:" + RESET);
                            int pages = Integer.parseInt(scanner.nextLine());
                            System.out.print(WHITE_BOLD + "price:" + RESET);
                            int price = Integer.parseInt(scanner.nextLine());
                            System.out.print(WHITE_BOLD + "how many authors?:" + RESET);
                            int count = Integer.parseInt(scanner.nextLine());
                            PreparedStatement pStatement = bs.con.prepareStatement("CALL res_proc_insert_book (?,?,?,?,?,?,?,?,?)");
                            pStatement.setInt(1, bs.loginID);
                            pStatement.setInt(2, book_id);
                            pStatement.setInt(3, volume);
                            pStatement.setString(4, title);
                            pStatement.setString(5, category);
                            pStatement.setString(6, publication);
                            pStatement.setString(7, publication_date);
                            pStatement.setInt(8, pages);
                            pStatement.setInt(9, price);
                            ResultSet rSet = pStatement.executeQuery();
                            if (rSet.next())
                                System.out.println(WHITE_BOLD + rSet.getString(1) + RESET);
                            rSet.close();
                            pStatement.close();
                            String author;
                            for (int i = 0; i < count; i++) {
                                System.out.println(WHITE_BOLD + "author:" + RESET);
                                author = scanner.nextLine();
                                pStatement = bs.con.prepareStatement("CALL res_proc_insert_author (?,?,?)");
                                pStatement.setInt(1, bs.loginID);
                                pStatement.setInt(2, book_id);
                                pStatement.setString(3, author);
                                rSet = pStatement.executeQuery();
                                if (rSet.next())
                                    System.out.println(WHITE_BOLD + rSet.getString(1) + RESET);
                                rSet.close();
                                pStatement.close();
                            }
                        } catch (Exception e) {
                            System.out.println(RED_BOLD + e + RESET);
                        }
                        break;
                    case "3":
                        System.out.println(WHITE_BOLD + "please fill this form:" + RESET);
                        System.out.print(WHITE_BOLD + "publication name:" + RESET);
                        String pub_name = scanner.nextLine();
                        System.out.print(WHITE_BOLD + "publication address:" + RESET);
                        String pub_address = scanner.nextLine();
                        System.out.print(WHITE_BOLD + "publication website:" + RESET);
                        String pub_website = scanner.nextLine();
                        try {
                            PreparedStatement pStatement = bs.con.prepareStatement("CALL res_proc_add_publication (?,?,?,?)");
                            pStatement.setInt(1, bs.loginID);
                            pStatement.setString(2, pub_name);
                            pStatement.setString(3, pub_address);
                            pStatement.setString(4, pub_website);
                            ResultSet rSet = pStatement.executeQuery();
                            if (rSet.next())
                                System.out.println(WHITE_BOLD + rSet.getString(1) + RESET);
                            rSet.close();
                            pStatement.close();
                        } catch (Exception e) {
                            System.out.println(RED_BOLD + e + RESET);
                        }
                        break;
                    case "4":
                        try {
                            System.out.print(WHITE_BOLD + "which page do you want ? (each page is 5 massages)" + RESET);
                            int pages = Integer.parseInt(scanner.nextLine());
                            PreparedStatement pStatement = bs.con.prepareStatement("CALL res_proc_messages (?,?)");
                            pStatement.setInt(1, bs.loginID);
                            pStatement.setInt(2, pages);
                            ResultSet rSet = pStatement.executeQuery();
                            System.out.println(YELLOW + "massages:" + RESET);
                            System.out.print(BLUE);
                            while (rSet.next()) {
                                System.out.println("    " + rSet.getString(1));
                            }
                            System.out.println(RESET);
                            rSet.close();
                            pStatement.close();
                        } catch (Exception e) {
                            System.out.println(RED_BOLD + e + RESET);
                        }
                        break;
                    case "5":
                        try {
                            PreparedStatement pStatement = bs.con.prepareStatement("CALL res_proc_see_delays (?)");
                            pStatement.setInt(1, bs.loginID);
                            ResultSet rSet = pStatement.executeQuery();
                            System.out.println(YELLOW + "book_id        title          volume         version        username       delay" + RESET);
                            int temp2;
                            System.out.print(BLUE);
                            while (rSet.next()) {
                                for (int i = 1; i <= 6; i++) {
                                    if (rSet.getString(i) != null) {
                                        System.out.print(rSet.getString(i));
                                        temp2 = 15 - rSet.getString(i).length();
                                    } else
                                        temp2 = 15;
                                    for (int j = 0; j < temp2; j++) {
                                        System.out.print(" ");
                                    }
                                }
                                System.out.println();
                            }
                            System.out.println(RESET);
                            rSet.close();
                            pStatement.close();
                        } catch (Exception e) {
                            System.out.println(RED_BOLD + e + RESET);
                        }
                        break;
                    case "6":
                        try {
                            System.out.println(WHITE_BOLD + "enter the book id you want" + RESET);
                            int book_id = Integer.parseInt(scanner.nextLine());
                            PreparedStatement pStatement = bs.con.prepareStatement("CALL res_proc_borrow_history (?,?)");
                            pStatement.setInt(1, bs.loginID);
                            pStatement.setInt(2, book_id);
                            ResultSet rSet = pStatement.executeQuery();
                            System.out.println(YELLOW + "title               volume              version             borrow              return" + RESET);
                            int temp2;
                            System.out.print(BLUE);
                            while (rSet.next()) {
                                for (int i = 1; i <= 5; i++) {
                                    if (rSet.getString(i) != null) {
                                        System.out.print(rSet.getString(i));
                                        temp2 = 20 - rSet.getString(i).length();
                                    } else
                                        temp2 = 20;
                                    for (int j = 0; j < temp2; j++) {
                                        System.out.print(" ");
                                    }
                                }
                                System.out.println();
                            }
                            System.out.println(RESET);
                            rSet.close();
                            pStatement.close();
                        } catch (Exception e) {
                            System.out.println(RED_BOLD + e + RESET);
                        }
                        break;
                    case "7":
                        try {
                            System.out.print(WHITE_BOLD + "Please enter part (or whole) of username:" + RESET);
                            String username = scanner.nextLine();
                            System.out.print(WHITE_BOLD + "Please enter part (or whole) of last name:" + RESET);
                            String last_name = scanner.nextLine();
                            System.out.print(WHITE_BOLD + "Please enter the page you want (each page has 5 results):" + RESET);
                            int page = Integer.parseInt(scanner.nextLine());
                            PreparedStatement pStatement = bs.con.prepareStatement("CALL res_proc_search_users (?,?,?,?)");
                            pStatement.setInt(1, bs.loginID);
                            pStatement.setString(2, username);
                            pStatement.setString(3, last_name);
                            pStatement.setInt(4, page);
                            ResultSet rSet = pStatement.executeQuery();
                            System.out.println(YELLOW + "customer_id    username       first_name     middle_initial last_name      balance        job            university     student_id     master_id      created_at" + RESET);
                            int temp2;
                            System.out.print(BLUE);
                            while (rSet.next()) {
                                for (int i = 1; i <= 11; i++) {
                                    if (rSet.getString(i) != null) {
                                        System.out.print(rSet.getString(i));
                                        temp2 = 15 - rSet.getString(i).length();
                                    } else
                                        temp2 = 15;
                                    for (int j = 0; j < temp2; j++) {
                                        System.out.print(" ");
                                    }
                                }
                                System.out.println();
                            }
                            System.out.println(RESET);
                            rSet.close();
                            pStatement.close();
                        } catch (Exception e) {
                            System.out.println(RED_BOLD + e + RESET);
                        }
                        break;
                    case "8":
                        try {
                            System.out.print(WHITE_BOLD + "please enter the username:" + RESET);
                            String username = scanner.nextLine();
                            PreparedStatement pStatement = bs.con.prepareStatement("CALL res_proc_users_history (?,?)");
                            pStatement.setInt(1, bs.loginID);
                            pStatement.setString(2, username);
                            ResultSet rSet = pStatement.executeQuery();
                            System.out.println(YELLOW + "logs:" + RESET);
                            System.out.print(BLUE);
                            while (rSet.next()) {
                                System.out.println("    " + rSet.getString(1));
                            }
                            System.out.println(RESET);
                            rSet.close();
                            pStatement.close();
                        } catch (Exception e) {
                            System.out.println(RED_BOLD + e + RESET);
                        }
                        break;
                    case "9":
                        System.out.println(WHITE_BOLD + "please fill this form:" + RESET);
                        System.out.print(WHITE_BOLD + "username:" + RESET);
                        String username = scanner.nextLine();
                        System.out.print(WHITE_BOLD + "password:" + RESET);
                        String password = scanner.nextLine();
                        System.out.print(WHITE_BOLD + "first name:" + RESET);
                        String f_name = scanner.nextLine();
                        System.out.print(WHITE_BOLD + "middle initial:" + RESET);
                        String m_name = scanner.nextLine();
                        System.out.print(WHITE_BOLD + "last name:" + RESET);
                        String l_name = scanner.nextLine();
                        System.out.print(WHITE_BOLD + "role (normal (nor) --- student (stu) --- master (mas) --- responsible (res)):" + RESET);
                        String role = scanner.nextLine();
                        System.out.print(WHITE_BOLD + "phone number:" + RESET);
                        String phone = scanner.nextLine();
                        System.out.print(WHITE_BOLD + "address:" + RESET);
                        String address = scanner.nextLine();
                        String job = null;
                        String student_id = null;
                        String university = null;
                        String master_id = null;
                        boolean flag = true;
                        switch (role) {
                            case "nor":
                                System.out.print(WHITE_BOLD + "job:" + RESET);
                                job = scanner.nextLine();
                                break;
                            case "stu":
                                System.out.print(WHITE_BOLD + "university:" + RESET);
                                university = scanner.nextLine();
                                System.out.print(WHITE_BOLD + "student id:" + RESET);
                                student_id = scanner.nextLine();
                                break;
                            case "mas":
                                System.out.print(WHITE_BOLD + "university:" + RESET);
                                university = scanner.nextLine();
                                System.out.print(WHITE_BOLD + "master id:" + RESET);
                                master_id = scanner.nextLine();
                                break;
                            case "res":
                                break;
                            default:
                                flag = false;
                                break;
                        }
                        if (flag) {
                            try {
                                PreparedStatement pStatement = bs.con.prepareStatement("CALL add_account (?,?,?,?,?,?,?,?,?,?,?,?)");
                                pStatement.setString(1, username);
                                pStatement.setString(2, password);
                                pStatement.setString(3, f_name);
                                pStatement.setString(4, m_name);
                                pStatement.setString(5, l_name);
                                pStatement.setString(6, role);
                                pStatement.setString(7, job);
                                pStatement.setString(8, university);
                                pStatement.setString(9, student_id);
                                pStatement.setString(10, master_id);
                                pStatement.setString(11, address);
                                pStatement.setString(12, phone);
                                ResultSet rSet = pStatement.executeQuery();
                                if (rSet.next()) {
                                    System.out.println(WHITE_BOLD + rSet.getString(1) + RESET);
                                }
                                rSet.close();
                                pStatement.close();
                            } catch (Exception e) {
                                System.out.println(RED_BOLD + e + RESET);
                            }
                        } else {
                            System.out.println(RED_BOLD + "you entered the role wrong!!" + RESET);
                        }
                        break;
                    case "10":
                        try {
                            System.out.println(WHITE_BOLD + "please enter the customer id you want to delete:");
                            int customer_id = Integer.parseInt(scanner.nextLine());
                            PreparedStatement pStatement = bs.con.prepareStatement("CALL res_proc_delete_account (? , ?)");
                            pStatement.setInt(1, bs.loginID);
                            pStatement.setInt(2, customer_id);
                            ResultSet rSet = pStatement.executeQuery();
                            if (rSet.next())
                                System.out.println(WHITE_BOLD + rSet.getString(1) + RESET);
                            rSet.close();
                            pStatement.close();
                        } catch (Exception e) {
                            System.out.println(RED_BOLD + e + RESET);
                        }
                        break;
                    case "0":
                        work = false;
                        break;
                    default:
                        System.out.println(RED_BOLD + "WRONG INPUT" + RESET);
                        break;
                }
            }
        } else {
            while (work) {
                System.out.println(WHITE_BOLD + "what can I do for you?" + RESET);
                System.out.println(WHITE_BOLD + "1.show my details" + RESET);
                System.out.println(WHITE_BOLD + "2.search a book" + RESET);
                System.out.println(WHITE_BOLD + "3.borrow a book" + RESET);
                System.out.println(WHITE_BOLD + "4.show my borrow list" + RESET);
                System.out.println(WHITE_BOLD + "5.return a book" + RESET);
                System.out.println(WHITE_BOLD + "6.add to my balance" + RESET);
                System.out.println(WHITE_BOLD + "0.exit" + RESET);
                input = scanner.nextLine();
                switch (input) {
                    case "1":
                        try {
                            PreparedStatement pStatement = bs.con.prepareStatement("CALL user_information_system (?)");
                            pStatement.setInt(1, bs.loginID);
                            ResultSet rSet = pStatement.executeQuery();
                            System.out.println(YELLOW + "username       first_name     middle_initial last_name      balance        job            university     student_id     master_id      created_at" + RESET);
                            int temp2;
                            System.out.print(BLUE);
                            while (rSet.next()) {
                                for (int i = 1; i <= 10; i++) {
                                    if (rSet.getString(i) != null) {
                                        System.out.print(rSet.getString(i));
                                        temp2 = 15 - rSet.getString(i).length();
                                    } else
                                        temp2 = 15;
                                    for (int j = 0; j < temp2; j++) {
                                        System.out.print(" ");
                                    }
                                }
                                System.out.println();
                            }
                            System.out.println(RESET);
                            rSet.close();
                            pStatement.close();
                            pStatement = bs.con.prepareStatement("CALL user_information_phones (?)");
                            pStatement.setInt(1, bs.loginID);
                            rSet = pStatement.executeQuery();
                            System.out.println(YELLOW + "phone numbers:" + RESET);
                            System.out.print(BLUE);
                            while (rSet.next()) {
                                System.out.println("     " + rSet.getString(1));
                            }
                            System.out.println(RESET);
                            rSet.close();
                            pStatement.close();
                            pStatement = bs.con.prepareStatement("CALL user_information_addresses (?)");
                            pStatement.setInt(1, bs.loginID);
                            rSet = pStatement.executeQuery();
                            System.out.println(YELLOW + "addresses:" + RESET);
                            System.out.print(BLUE);
                            while (rSet.next()) {
                                System.out.println("     " + rSet.getString(1));
                            }
                            System.out.println(RESET);
                            rSet.close();
                            pStatement.close();
                        } catch (Exception e) {
                            System.out.println(RED_BOLD + e + RESET);
                        }
                        break;
                    case "2":
                        System.out.print(WHITE_BOLD + "Please enter part (or whole) of the book title:" + RESET);
                        String title = scanner.nextLine();
                        System.out.print(WHITE_BOLD + "Please enter part (or whole) of the author name:" + RESET);
                        String author = scanner.nextLine();
                        System.out.print(WHITE_BOLD + "Please enter part (or whole) of the book version:" + RESET);
                        String version = scanner.nextLine();
                        System.out.print(WHITE_BOLD + "Please enter part (or whole) of the publication date (please use this format -> YYYY-MM-DD):" + RESET);
                        String pub_date = scanner.nextLine();
                        try {
                            PreparedStatement pStatement = bs.con.prepareStatement("CALL user_proc_search (?,?,?,?,?)");
                            pStatement.setInt(1, bs.loginID);
                            pStatement.setString(2, title);
                            pStatement.setString(3, author);
                            pStatement.setString(4, version);
                            pStatement.setString(5, pub_date);
                            ResultSet rSet = pStatement.executeQuery();
                            System.out.println(WHITE_BOLD + "cases that matches" + RESET);
                            System.out.println(YELLOW + "book_id        volume         title          category       pub_name       pub_date       pages          price" + RESET);
                            int temp2;
                            System.out.print(BLUE);
                            while (rSet.next()) {
                                for (int i = 1; i <= 8; i++) {
                                    if (rSet.getString(i) != null) {
                                        System.out.print(rSet.getString(i));
                                        temp2 = 15 - rSet.getString(i).length();
                                    } else
                                        temp2 = 15;
                                    for (int j = 0; j < temp2; j++) {
                                        System.out.print(" ");
                                    }
                                }
                                System.out.println();
                            }
                            System.out.println(RESET);
                            rSet.close();
                            pStatement.close();
                        } catch (Exception e) {
                            System.out.println(RED_BOLD + e + RESET);
                        }
                        break;
                    case "3":
                        try {
                            System.out.println(WHITE_BOLD + "please enter the book id:" + RESET);
                            int book_id = Integer.parseInt(scanner.nextLine());
                            System.out.println(WHITE_BOLD + "please enter the volume(if it has 1 volume just enter 1):" + RESET);
                            int volume = Integer.parseInt(scanner.nextLine());
                            PreparedStatement pStatement = bs.con.prepareStatement("CALL user_proc_borrow (?,?,?)");
                            pStatement.setInt(1, bs.loginID);
                            pStatement.setInt(2, book_id);
                            pStatement.setInt(3, volume);
                            ResultSet rSet = pStatement.executeQuery();
                            if (rSet.next())
                                System.out.println(WHITE_BOLD + rSet.getString(1) + RESET);
                            rSet.close();
                            pStatement.close();
                        } catch (Exception e) {
                            System.out.println(RED_BOLD + e + RESET);
                        }
                        break;
                    case "4":
                        try {
                            PreparedStatement pStatement = bs.con.prepareStatement("CALL user_proc_borrow_list (?)");
                            pStatement.setInt(1, bs.loginID);
                            ResultSet rSet = pStatement.executeQuery();
                            System.out.println(YELLOW + "borrow_id           book_id             title               volume              start_borrow        return_borrow" + RESET);
                            int temp2;
                            System.out.print(BLUE);
                            while (rSet.next()) {
                                for (int i = 1; i <= 6; i++) {
                                    if (rSet.getString(i) != null) {
                                        System.out.print(rSet.getString(i));
                                        temp2 = 20 - rSet.getString(i).length();
                                    } else
                                        temp2 = 20;
                                    for (int j = 0; j < temp2; j++) {
                                        System.out.print(" ");
                                    }
                                }
                                System.out.println();
                            }
                            System.out.println(RESET);
                            rSet.close();
                            pStatement.close();
                        } catch (Exception e) {
                            System.out.println(RED_BOLD + e + RESET);
                        }
                        break;
                    case "5":
                        try {
                            System.out.println(WHITE_BOLD + "please enter the borrow id:" + RESET);
                            int borrow_id = Integer.parseInt(scanner.nextLine());
                            PreparedStatement pStatement = bs.con.prepareStatement("CALL user_proc_return (?,?)");
                            pStatement.setInt(1, bs.loginID);
                            pStatement.setInt(2, borrow_id);
                            ResultSet rSet = pStatement.executeQuery();
                            if (rSet.next())
                                System.out.println(WHITE_BOLD + rSet.getString(1) + RESET);
                            rSet.close();
                            pStatement.close();
                        } catch (Exception e) {
                            System.out.println(RED_BOLD + e + RESET);
                        }
                        break;
                    case "6":
                        try {
                            System.out.println(WHITE_BOLD + "how much do you want to increase?:" + RESET);
                            int value = Integer.parseInt(scanner.nextLine());
                            PreparedStatement pStatement = bs.con.prepareStatement("CALL user_proc_add_balance (?,?)");
                            pStatement.setInt(1, bs.loginID);
                            pStatement.setInt(2, value);
                            ResultSet rSet = pStatement.executeQuery();
                            if (rSet.next())
                                System.out.println(WHITE_BOLD + rSet.getString(1) + RESET);
                            rSet.close();
                            pStatement.close();
                        } catch (Exception e) {
                            System.out.println(RED_BOLD + e + RESET);
                        }

                        break;
                    case "0":
                        work = false;
                        break;
                    default:
                        System.out.println(RED_BOLD + "WRONG INPUT" + RESET);
                        break;
                }
            }
        }
        try {
            PreparedStatement pStatement = bs.con.prepareStatement("CALL make_expire (?)");
            pStatement.setInt(1, bs.loginID);
            pStatement.executeQuery();
            pStatement.close();
            bs.con.close();
            System.out.println(GREEN_BOLD + "you have successfully logged out" + RESET);
        } catch (Exception e) {
            System.out.println(RED_BOLD + e + RESET);
        }
    }
}