package com.emrBean;

import java.sql.Timestamp;

public class HistoryBean {
    private String id;
    private String employeeId;
    private String patientId;
    private String deptId;
    private String memo;
    private int bpSystolic;
    private int bpDiastolic;
    private float height;
    private float weight;
    private float temp;
    private String symptomDetail;
    private Timestamp entryDate;

    // Getters & Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getEmployeeId() { return employeeId; }
    public void setEmployeeId(String employeeId) { this.employeeId = employeeId; }

    public String getPatientId() { return patientId; }
    public void setPatientId(String patientId) { this.patientId = patientId; }

    public String getDeptId() { return deptId; }
    public void setDeptId(String deptId) { this.deptId = deptId; }

    public String getMemo() { return memo; }
    public void setMemo(String memo) { this.memo = memo; }

    public int getBpSystolic() { return bpSystolic; }
    public void setBpSystolic(int bpSystolic) { this.bpSystolic = bpSystolic; }

    public int getBpDiastolic() { return bpDiastolic; }
    public void setBpDiastolic(int bpDiastolic) { this.bpDiastolic = bpDiastolic; }

    public float getHeight() { return height; }
    public void setHeight(float height) { this.height = height; }

    public float getWeight() { return weight; }
    public void setWeight(float weight) { this.weight = weight; }

    public float getTemp() { return temp; }
    public void setTemp(float temp) { this.temp = temp; }

    public String getSymptomDetail() { return symptomDetail; }
    public void setSymptomDetail(String symptomDetail) { this.symptomDetail = symptomDetail; }

    public Timestamp getEntryDate() { return entryDate; }
    public void setEntryDate(Timestamp entryDate) { this.entryDate = entryDate; }
}
