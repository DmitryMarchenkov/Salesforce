public class MainProjectPageController {

    public String selectedValue { get;set; }
    public List<SelectOption> statusOptions { get;set; }
    public List<Material__c> materials { get;set; }
    public Map<Id, Attachment> materialsWithAttachment {get;set;}

    public Attachment attachment {get; set;}

    public Boolean mainButtonFlag {get; set;}
    public Boolean scheduleButtonFlag {get; set;}
    public Boolean scheduleShow {get; set;}
    public Boolean materialsButtonFlag {get; set;}
    public Boolean addAttachmentFlag {get; set;}
    public Date scheduleDate {get; set;}
    
    public Attachment attachedFile {get; set;}
    public Schedule__c schedule {get; set;}
    public Material__c material {get; set;}
    public Notation__c note {get; set;}

    public MainProjectPageController() {
        scheduleShow = false;
        mainButtonFlag = true;
        scheduleButtonFlag = false;
        materialsButtonFlag = false; 
        addAttachmentFlag = true;

        getAttachmentByDate(null);
    
        note = [SELECT Note__c FROM Notation__c LIMIT 1].[0];
        schedule = new Schedule__c();
        material = new Material__c();
        attachedFile = New Attachment();
        scheduleDate = Date.today();
        autoRun();
    }

    public PageReference mainButtonAction() {    
        addAttachmentFlag = true;
        mainButtonFlag = true;
        scheduleButtonFlag = false;
        materialsButtonFlag = false;
        scheduleShow = false;        
        return null;
    }

    public PageReference scheduleButtonAction() {  
        addAttachmentFlag = true;
        mainButtonFlag = false;
        scheduleButtonFlag = true;
        materialsButtonFlag = false;
        scheduleShow = false;
        return null;
    }

    public PageReference materialsButtonAction() {   
        addAttachmentFlag = true;
        mainButtonFlag = false;
        scheduleButtonFlag = false;
        materialsButtonFlag = true;
        scheduleShow = false;
        return null;
    }
    
    public void showSchedule() {
        getAttachmentByDate(scheduleDate);
        addAttachmentFlag = true;
    }
    
    public PageReference addAttachment(){
        addAttachmentFlag = false;
        scheduleShow = false;
        return null; 
    }  

    public void UploadFileAttachmentSchedule() {        
        insert schedule;
        attachedFile.ParentId = schedule.Id;
        insert attachedFile;  
        addAttachmentFlag = true;
    }

    public void UploadFileAttachmentMaterial() {        
        insert material;
        attachedFile.ParentId = material.Id;
        insert attachedFile;  
        addAttachmentFlag = true;
    }

    private void getAttachmentByDate(Date scheduleDate) {
        if(scheduleDate == null) {
            scheduleDate = Date.today();
        }

        try {
            List<Schedule__c> sched = [SELECT Id FROM Schedule__c WHERE ScheduleDate__c = :scheduleDate LIMIT 1];
            attachment = [SELECT Id, ParentId FROM Attachment WHERE ParentId = :sched[0].Id ];
            scheduleShow = true;            
        } catch(Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.FATAL, 'Schedule on this date doesn\'t exist!');
            System.debug(e);
            ApexPages.addMessage(errorMessage);
        }
    }

    private void saveAttachment() {

    }

    public void autoRun()
    {
        Schema.DescribeFieldResult statusFieldDescription = Material__c.Theme__c.getDescribe();
        statusOptions = new list<SelectOption>();
        
        for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues())
        {
            statusOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
        }
    }

    public void showMaterials()
    {
        materialsWithAttachment = new Map<Id, Attachment>();
        Set<Id> materialsIds = new Set<Id>();

        materials = [SELECT Id, Name FROM Material__c WHERE Theme__c = :selectedValue ORDER BY Name];
        for(Material__c material: materials) {
            materialsIds.add(material.Id);
        }

        for(Attachment attachment: [SELECT Id, ParentId FROM Attachment WHERE ParentId IN :materialsIds]) {
            materialsWithAttachment.put(attachment.ParentId, attachment);
        }
    }
}
