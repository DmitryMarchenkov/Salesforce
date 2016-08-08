public class CalculateBonuses {
private List<Timelog_Entry__c> timeLogs;
private Decimal summOvertime = 0;

	public String calcBonuse(Resource__c resource) {
		if (!resource.isFired__c) {
			List<Timelog_Entry__c> timeLogs = [
				SELECT Id, Project__c, Working_Hours__c
				FROM Timelog_Entry__c
				WHERE Resource__c = :resource.Id AND Start_Date__c = LAST_N_DAYS:30
			];

			if (timeLogs.isEmpty()) {
				throw new ResourceDoesntHaveTimelogs('Resource: ' + resource + ' doesn\'t have timelogs');
			} 
			
			return calculateOvertime(resource);

		} else {
			throw new ResourceIsFiredException('Resource: ' + resource + ' is fired.');
		}
	}

	public String calculateOvertime(Resource__c resource) {
		List<ResourcePermission__c> resourcePermisions = getResourcePermissionByResource(resource);

		for(Timelog_Entry__c timeLog : timeLogs) {
			for(ResourcePermission__c resourcePermision : resourcePermisions) {
				if(timeLog.Project__c == resourcePermision.Project__c) {
					resourcePermision.Overtime_Hours__c = timeLog.Working_Hours__c - resourcePermision.Project__r.Contract_Time__c;
				}
			}
		}
		update resourcePermisions;
		
		for(ResourcePermission__c resourcePermision : resourcePermisions) {
			summOvertime += resourcePermision.Overtime_Hours__c * resourcePermision.Project__r.OverTime_Rate__c;
		}

		return summOvertime.toPlainString();
	}

	private List<ResourcePermission__c> getResourcePermissionByResource(Resource__c resource) {
		List<ResourcePermission__c> resourcePermission = [
			SELECT Id, Project__c, Project__r.OverTime_Rate__c, Project__r.Contract_Time__c
			FROM ResourcePermission__c
			WHERE Resource__c = :resource.Id
		];
		return resourcePermission;
	}

	public class ResourceIsFiredException extends Exception{}
	public class ResourceDoesntHaveTimelogs extends Exception{}
}
