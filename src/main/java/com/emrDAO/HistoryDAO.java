package com.emrDAO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.*;
import com.emrBean.HistoryBean;

public class HistoryDAO {
    private Connection conn;
    private PreparedStatement pstmt;
    private ResultSet rs;

    private static HistoryDAO instance = new HistoryDAO();
    public static HistoryDAO getInstance() { return instance; }

    private HistoryDAO() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/bitcare?serverTimezone=Asia/Seoul",
                "dbtest", 
                "password"
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** 특정 환자의 과거 진료 기록 조회 */
    public List<HistoryBean> getHistoryByPatient(String patientId) {
        List<HistoryBean> list = new ArrayList<>();
        try {
            String sql = "SELECT * FROM history WHERE patient_id = ? ORDER BY entry_date DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, patientId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                HistoryBean h = new HistoryBean();
                h.setId(rs.getString("id"));
                h.setEmployeeId(rs.getString("employee_id"));
                h.setPatientId(rs.getString("patient_id"));
                h.setDeptId(rs.getString("dept_id"));
                h.setMemo(rs.getString("memo"));
                h.setBpSystolic(rs.getInt("bp_systolic"));
                h.setBpDiastolic(rs.getInt("bp_diastolic"));
                h.setHeight(rs.getFloat("height"));
                h.setWeight(rs.getFloat("weight"));
                h.setTemp(rs.getFloat("temp"));
                h.setSymptomDetail(rs.getString("symptom_detail"));
                h.setEntryDate(rs.getTimestamp("entry_date"));
                list.add(h);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** 새 진료 기록 저장 */
    public boolean insertHistory(HistoryBean h) {
        try {
            String sql = "INSERT INTO history (id, employee_id, patient_id, dept_id, memo, bp_systolic, bp_diastolic, height, weight, temp, symptom_detail, entry_date) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, h.getId());
            pstmt.setString(2, h.getEmployeeId());
            pstmt.setString(3, h.getPatientId());
            pstmt.setString(4, h.getDeptId());
            pstmt.setString(5, h.getMemo());
            pstmt.setInt(6, h.getBpSystolic());
            pstmt.setInt(7, h.getBpDiastolic());
            pstmt.setFloat(8, h.getHeight());
            pstmt.setFloat(9, h.getWeight());
            pstmt.setFloat(10, h.getTemp());
            pstmt.setString(11, h.getSymptomDetail());
            int result = pstmt.executeUpdate();
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    public boolean updateHistory(HistoryBean h) {
        try {
            String sql = "UPDATE history SET memo=?, symptom_detail=?, bp_systolic=?, bp_diastolic=?, temp=?, weight=? WHERE id=?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, h.getMemo());
            pstmt.setString(2, h.getSymptomDetail());
            pstmt.setInt(3, h.getBpSystolic());
            pstmt.setInt(4, h.getBpDiastolic());
            pstmt.setFloat(5, h.getTemp());
            pstmt.setFloat(6, h.getWeight());
            pstmt.setString(7, h.getId()); // 수정할 기록의 ID (WHERE 조건)
            
            int result = pstmt.executeUpdate();
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
 // [추가] ID로 특정 진료 기록 1건 조회
    public HistoryBean getHistoryById(String id) {
        HistoryBean h = null;
        try {
            String sql = "SELECT * FROM history WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                h = new HistoryBean();
                h.setId(rs.getString("id"));
                h.setEmployeeId(rs.getString("employee_id"));
                h.setPatientId(rs.getString("patient_id"));
                h.setDeptId(rs.getString("dept_id"));
                h.setMemo(rs.getString("memo"));
                h.setSymptomDetail(rs.getString("symptom_detail"));
                h.setBpSystolic(rs.getInt("bp_systolic"));
                h.setBpDiastolic(rs.getInt("bp_diastolic"));
                h.setTemp(rs.getFloat("temp"));
                h.setWeight(rs.getFloat("weight"));
                h.setHeight(rs.getFloat("height"));
                h.setEntryDate(rs.getTimestamp("entry_date"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return h;
    }
}
