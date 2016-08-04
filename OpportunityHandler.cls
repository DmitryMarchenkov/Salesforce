public class OpportunityHandler {
	
	public static void insertTenOLIsPerOpportunity(List<Opportunity> oppList) {
		List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
		List<PriceBookEntry> priceBookList = [
			SELECT Id
			FROM PriceBookEntry 
			LIMIT 1];

		for(Opportunity opp : oppList) {
			for(Integer i = 0; i < 10; i++) {
				OpportunityLineItem oli = new OpportunityLineItem(
					OpportunityId = opp.Id,
					Quantity = 5,
					TotalPrice = 20,
					PricebookEntryId = priceBookList[0].Id);
				oliList.add(oli);
			}
		}
		insert oliList;
	}

	public static void recalculateOpportunitiesAmount(List<Opportunity> oppList) {
		Map<Id, Decimal> oppsWithAmount = new Map<Id, Decimal>();

		List<OpportunityLineItem> oppLineItems = returnOppLineItemsForOpportunity(oppList);

		for(OpportunityLineItem oppLI : oppLineItems) {
			if(oppsWithAmount.containsKey(oppLI.OpportunityId)) {
				oppsWithAmount.put(oppLI.OpportunityId, oppsWithAmount.get(oppLI.OpportunityId) + oppLI.TotalPrice);
			} else {
				oppsWithAmount.put(oppLI.OpportunityId, oppLI.TotalPrice);
			}
		}

		for(Opportunity opp : oppList) {
			for(Id oppId : oppsWithAmount.keySet()) {
				if(opp.Id == oppId) {
					opp.Amount = oppsWithAmount.get(oppId);
				}
			}
		}
		update oppList;
	} 

	public static void doubleAmountOfEveryOpportunity(List<Opportunity> oppList) {
		List<OpportunityLineItem> oppLineItemsForDoubling = returnOppLineItemsForOpportunity(oppList);

		for(OpportunityLineItem oppLI : oppLineItemsForDoubling) {
			oppLI.TotalPrice = oppLI.TotalPrice*2;
		}

		update oppLineItemsForDoubling;
		recalculateOpportunitiesAmount(oppList);
	}

	private static List<OpportunityLineItem> returnOppLineItemsForOpportunity(List<Opportunity> opportunities) {
		Set<Id> oppIds = new Set<Id>();

		for(Opportunity opp : opportunities) {
			oppIds.add(opp.Id);
		}

		List<OpportunityLineItem> oppLItems = [
			SELECT Id, TotalPrice, OpportunityId
			FROM OpportunityLineItem
			WHERE OpportunityId IN :oppIds
		];
		return oppLItems;
	}
}
