public class CalculateBonuses {
private List<Timelog_Entry__c> timeLogs;
Decimal sumOvertime = 0;

	public String calcBonuse(Resource__c resource) {
		if (!resource.isFired__c) {
			List<Timelog_Entry__c> timeLogs = [
				SELECT Id, Project__c, Working_Hours__c
				FROM Timelog_Entry__c
				WHERE Resource__c = :resource.Id AND Start_Date__c = LAST_N_DAYS:30
			];

			if (timeLogs.isEmpty()) {
				return 'A-HA-HA. Resource: ' + resource + ' doesn\'t have timelogs';	
			} 
			
			return calculateOvertime(resource);

		} else {
			throw new ResourceIsFiredException('A-HA-HA. Resource: ' + resource + ' is fired.');
		}
	}

	public String calculateOvertime(Resource__c resource) {
		List<ResourcePermission__c> resPermisions = getResourcePermissionByResource(resource);

		for(Timelog_Entry__c timeLog : timeLogs) {
			for(ResourcePermission__c resPerm : resPermisions) {
				if(timeLog.Project__c == resPerm.Project__c) {
					resPerm.Overtime_Hours__c = timeLog.Working_Hours__c - resPerm.Project__r.Contract_Time__c;
				}
			}
		}
		update resPermisions;
		
		for(ResourcePermission__c resPerm : resPermisions) {
			sumOvertime += resPerm.Overtime_Hours__c * resPerm.Project__r.OverTime_Rate__c;
		}

		return sumOvertime.toPlainString();
	}

	private List<ResourcePermission__c> getResourcePermissionByResource(Resource__c resource) {
		List<ResourcePermission__c> resPermis = [
			SELECT Id, Project__c, Project__r.OverTime_Rate__c, Project__r.Contract_Time__c
			FROM ResourcePermission__c
			WHERE Resource__c = :resource.Id
		];
		return resPermis;
	}

	public class ResourceIsFiredException extends Exception{}
}
