package com.emrDAO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.emrBean.*;

public class MemberDAO {

    // 기본 생성자
    public MemberDAO() {}

    // 회원가입 메서드
    public void joinMember(MemberBean bean) {
        Connection conn = null;
        PreparedStatement pstm = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String jdbcurl = "jdbc:mysql://localhost:3306/bitcare?serverTimezone=UTC";
            conn = DriverManager.getConnection(jdbcurl, "dbtest", "password");
            conn.setAutoCommit(false);

            // user_id를 포함한 명시적 INSERT
            String query = "INSERT INTO employee (id, password, name, email, phone, role) VALUES (?, ?, ?, ?, ?, ?)";

            pstm = conn.prepareStatement(query);
            pstm.setString(1, bean.getId());
            pstm.setString(2, bean.getPw());
            pstm.setString(3, bean.getName());
            pstm.setString(4, bean.getEmail());
            pstm.setString(5, bean.getPhone());
            pstm.setString(6, "USER");

            pstm.executeUpdate();
            conn.commit();
            System.out.println("✅ 회원가입 성공");

        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException se) {
                se.printStackTrace();
            }
            e.printStackTrace();
            throw new RuntimeException(e.getMessage());
        } finally {
            try {
                if (pstm != null) pstm.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                throw new RuntimeException(e.getMessage());
            }
        }
    }

    public boolean isIDExists(MemberBean bean) {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        boolean exists = false;
        String ID=bean.getId(); 
        String dbID;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String jdbcurl = "jdbc:mysql://localhost:3306/bitcare?serverTimezone=UTC";
            conn = DriverManager.getConnection(jdbcurl, "dbtest", "password");

            // 쿼리 - 아이디가 이미 존재하는지 확인
            String query = "select * from employee";
            stmt=conn.createStatement();
            rs=stmt.executeQuery(query);
          
            while(rs.next()) {
            	dbID=rs.getString("id");
            	if(ID.equals(dbID)) {
            		exists=true;
            		break;
            	}
            }
            
            return exists;

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException(e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                throw new RuntimeException(e.getMessage());
            }
        }

        
    }
	//디비에서 특정 회원의 정보를 가져와 Bean에 저장하는 함수
    public MemberBean getMember(String strId) {
    	Connection conn = null;
        Statement stmt = null;
        PreparedStatement pstmt=null;
        ResultSet rs = null;
              
        String dbNAME, dbID, dbPW, dbEMAIL, dbPHONE;
        MemberBean memberbean=new MemberBean();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String jdbcurl = "jdbc:mysql://localhost:3306/bitcare?serverTimezone=UTC";
            conn = DriverManager.getConnection(jdbcurl, "dbtest", "password");

            // 쿼리 - 회원의 아이디와 비번이 매치하는지 확인
            
            //String query = "select * from member where id='" + strId + "'";
           // stmt=conn.createStatement();
           // rs=stmt.executeQuery(query);
           
            
            String query = "SELECT * FROM employee WHERE id = ?";
            pstmt = conn.prepareStatement(query);
            pstmt.setString(1, strId); // ?에 strId 값을 바인딩
            rs = pstmt.executeQuery();
          
            while(rs.next()) {
            	dbNAME=rs.getString("name");
            	dbID=rs.getString("id");
            	dbPW=rs.getString("pw");
            	dbEMAIL=rs.getString("email");
            	dbPHONE=rs.getString("phone");
            	
            	memberbean.setName(dbNAME);
                memberbean.setId(dbID);
                memberbean.setPw(dbPW);
                memberbean.setEmail(dbEMAIL);
                memberbean.setPhone(dbPHONE);
            }
            
            
            
            return memberbean;

        } 
        catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException(e.getMessage());
        } 
        finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                throw new RuntimeException(e.getMessage());
            }
        }
    }
}

/*public class MemberDAO {
	--
	private static MemberDAO instance;
	private MemberDAO(){}
	//싱글톤 패턴
	public static MemberDAO getInstance(){
	if(instance == null ) instance = new MemberDAO();
	return instance;
	}
	--
	
	//기본생성자
	public MemberDAO() {}
	
	// 회원가입 메서드
	public void joinMember(MemberBean bean) {
	Connection conn = null;
	PreparedStatement pstm = null;

	try {
		Class.forName("com.mysql.jdbc.Driver");
		String jdbcurl="jdbc:mysql://localhost:3306/bitcare?serverTimezone=UTC";
		conn=DriverManager.getConnection(jdbcurl,"dbtest","password");
		
		// 3. Auto-commit 비활성화
	    conn.setAutoCommit(false);
		
        //중복이 아니면 회원가입 정보 디비에 저장
		// 쿼리
		String query = "INSERT INTO employee VALUES(?,?,?,?,?)";
		pstm = conn.prepareStatement(query);
		// MemberBean에 담긴 값을 가져와 쿼리문에 세팅
		pstm.setString(1, bean.getName());
		pstm.setString(2, bean.getId());
		pstm.setString(3, bean.getPw());
		pstm.setString(4, bean.getEmail());
		pstm.setString(5, bean.getPhone());
		
		// 쿼리 실행
		pstm.executeUpdate();
		// 완료시 커밋
		conn.commit();
		//return "success";
		} 
	
	catch (Exception sqle) {
		try {
		conn.rollback(); // 오류 시 롤백
		} catch (SQLException e) {
		e.printStackTrace();
		}
		throw new RuntimeException(sqle.getMessage());
		}
	
    finally {
		try {
			if (pstm != null) {
				pstm.close();
				pstm = null;
			}
			if (conn != null) {
				conn.close();
				conn = null;
			}
		} catch (Exception e) {
			throw new RuntimeException(e.getMessage());
		}
		}
	} // end joinMember()
	
///-----------------------------------------------------
		
	//ID로 중복 체크 메소드
    public boolean isIDExists(MemberBean bean) {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        boolean exists = false;
        String ID=bean.getId(); 
        String dbID;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String jdbcurl = "jdbc:mysql://localhost:3306/bitcare?serverTimezone=UTC";
            conn = DriverManager.getConnection(jdbcurl, "dbtest", "password");

            // 쿼리 - 아이디가 이미 존재하는지 확인
            String query = "select * from employee";
            stmt=conn.createStatement();
            rs=stmt.executeQuery(query);
          
            while(rs.next()) {
            	dbID=rs.getString("id");
            	if(ID.equals(dbID)) {
            		exists=true;
            		break;
            	}
            }
            
            return exists;

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException(e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                throw new RuntimeException(e.getMessage());
            }
        }

        
    }
    
    //--------------------------------------------------
	//디비에서 특정 회원의 정보를 가져와 Bean에 저장하는 함수
    public MemberBean getMember(String strId) {
    	Connection conn = null;
        Statement stmt = null;
        PreparedStatement pstmt=null;
        ResultSet rs = null;
              
        String dbNAME, dbID, dbPW, dbEMAIL, dbPHONE;
        MemberBean memberbean=new MemberBean();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String jdbcurl = "jdbc:mysql://localhost:3306/bitcare?serverTimezone=UTC";
            conn = DriverManager.getConnection(jdbcurl, "dbtest", "password");

            // 쿼리 - 회원의 아이디와 비번이 매치하는지 확인
            
            //String query = "select * from member where id='" + strId + "'";
           // stmt=conn.createStatement();
           // rs=stmt.executeQuery(query);
           
            
            String query = "SELECT * FROM employee WHERE id = ?";
            pstmt = conn.prepareStatement(query);
            pstmt.setString(1, strId); // ?에 strId 값을 바인딩
            rs = pstmt.executeQuery();
          
            while(rs.next()) {
            	dbNAME=rs.getString("name");
            	dbID=rs.getString("id");
            	dbPW=rs.getString("password");
            	dbEMAIL=rs.getString("email");
            	dbPHONE=rs.getString("phone");
            	
            	memberbean.setName(dbNAME);
                memberbean.setId(dbID);
                memberbean.setPw(dbPW);
                memberbean.setEmail(dbEMAIL);
                memberbean.setPhone(dbPHONE);
            }
            
            
            
            return memberbean;

        } 
        catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException(e.getMessage());
        } 
        finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                throw new RuntimeException(e.getMessage());
            }
        }
    } //getMember 메소드 종료
    //--------------------------------------------------
    
    
 // 이메일 중복 체크 메소드
    /*
    public boolean isEmailExists(String email, String emailDomain,MemberBean bean) {
    	 Connection conn = null;
         Statement stmt = null;
         ResultSet rs = null;
         String EMAIL, EMAILDOMAIN;
         boolean exists=false;       
         
         try {
             Class.forName("com.mysql.cj.jdbc.Driver");
             String jdbcurl = "jdbc:mysql://localhost:3306/wptest?serverTimezone=UTC";
             conn = DriverManager.getConnection(jdbcurl, "root", "0000");

             //이메일중복확인
             String query = "select * from member";
             stmt=conn.createStatement();
             rs=stmt.executeQuery(query);
           
             while(rs.next()) {
            	EMAIL=rs.getString("email");
            	EMAILDOMAIN=rs.getString("emaildomain");
             	if((bean.getEmail()).equals(EMAIL) && (bean.getEmailDomain()).equals(EMAILDOMAIN)) {
             		exists=true;
             		break;
             	}
             }           
             return exists;         
             
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return exists;
    }
    --
    
    
    
}	
*/
