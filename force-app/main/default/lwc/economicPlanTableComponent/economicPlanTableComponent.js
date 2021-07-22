/**
 * @description       : JS Controller for LWC EconomicPlanTableComponent
 * @author            : Œ | Mirco Centrone
 * @last modified on  : 19-07-2021
 * @last modified by  : Œ
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   04-02-2021   Œ   Initial Version
 * 1.1   26-04-2021   Œ   Modifiche all'algoritmo di approvazione e calcolo dell'economicPlan, richieste dal cliente.
 **/
import { LightningElement, wire, api, track } from 'lwc';
import getEconomicPlan from '@salesforce/apex/EconomicPlanController.getEconomicPlan';
import getTotalEconomicPlan from '@salesforce/apex/EconomicPlanController.getTotalEconomicPlan'
import setQuoteIsMarginValid from '@salesforce/apex/EconomicPlanController.setQuoteIsMarginValid'
import { refreshApex } from '@salesforce/apex';
import { subscribe, unsubscribe } from 'lightning/empApi';


export default class EconomicPlanTable extends LightningElement {

    @api recordId;

    @track recordsBuffer;
    @track recordsBuffer2;

    @track economicPlan = [];
    @track economicPlanSize;
    @track totalEconomicPlan = [];
    @track marginCheck;
    @track totalLinksRevenue;
    @track totalMarginCheck;
    @track totalMinMargin;
    @track totalMinMarginPercent;
    @track totalMargin;
    @track costHRMargin;
    @track costMargin;
    @track rowError;

    @track error = [];
    @track error2 = [];
    @track error3 = [];

    subscription1 = {};
    subscription2 = {};
    subscription3 = {};

    @wire
        (getEconomicPlan, { quoteID: '$recordId' })
    economicPlan(recordsBuffer) {
        this.recordsBuffer = recordsBuffer;
        const { data, error } = recordsBuffer;
        if (data) {
            this.economicPlan = data;
            this.error = undefined;
            this.economicPlanSize = data.length;
            //console.log('Œ economicPlan => ', JSON.stringify(data));
            this.marginIsValid();
        } else if (error) {
            this.error = error;
            this.economicPlan = undefined;
            console.error('Œ ERROR => ', JSON.stringify(error));
        }
    };

    @wire
        (getTotalEconomicPlan, { quoteId: '$recordId' })
    totalEconomicPlan(recordsBuffer2) {
        this.recordsBuffer2 = recordsBuffer2;
        const { data, error } = recordsBuffer2;
        if (data) {
            this.totalEconomicPlan = data;
            if (data.cost != 0 || data.costHR != 0) {
                this.costHRMargin = Math.round((data.costHR / (data.cost + data.costHR)) * data.margin);
                this.costMargin = Math.round((data.cost / (data.cost + data.costHR)) * data.margin);
                this.marginIsValid();
            } else {
                this.costHRMargin = 0;
                this.costMargin = 0;
            }
            this.error2 = undefined;
            //console.log('Œ totalEconomicPlan => ', JSON.stringify(data));

        } else if (error) {
            this.error2 = error;
            this.totalEconomicPlan = undefined;
            console.error('Œ ERROR => ', JSON.stringify(error));
        }
    };

    @api
    async refresh() {
        console.log('Œ Refresh Table');
        refreshApex(this.recordsBuffer);
        refreshApex(this.recordsBuffer2);
        return;
    };

    /** 
     * @description : Check if every Revenue Type marginCheck is True, if totalMargin > totalMinMargin, and then calls setQuoteIsMarginValid Apex Method
    **/
    marginIsValid() {
        this.marginCheck = true;
        this.totalMarginCheck = false;
        this.totalMinMargin = 0;
        this.totalMargin = 0;
        this.totalLinksRevenue = 0;
        this.rowError = false;

        this.economicPlan.forEach(element => {
            this.totalMargin += element.margin;
            this.totalMinMargin += element.minMargin;
            this.totalLinksRevenue += element.linksRevenue;

            if (this.marginCheck == true) {
                if (element.marginCheck) {
                    this.marginCheck = true;
                } else {
                    this.marginCheck = false;
                }
            }
            if (element.rowError == true) {
                this.rowError = true;
            }
        });

        if (this.totalLinksRevenue != 0) {
            this.totalMinMarginPercent = this.totalMinMargin / this.totalLinksRevenue;
        } else {
            this.totalMinMarginPercent = 0;
        }

        if (this.totalMargin < this.totalMinMargin || this.economicPlanSize == 0 || this.rowError == true) {
            this.totalMarginCheck = false;
        } else {
            this.totalMarginCheck = true;
        }
        console.log('Œ costHRMargin => ', JSON.stringify(this.costHRMargin));
        console.log('Œ costMargin => ', JSON.stringify(this.costMargin));
        let CustomWrapper = {
            quoteId: this.recordId,
            marginCheck: this.marginCheck,
            totalMarginCheck: this.totalMarginCheck,
            costHRMargin: this.costHRMargin,
            costMargin: this.costMargin
        };
        console.log('totalMarginCheck ' + this.totalMarginCheck);
        setQuoteIsMarginValid({ wrapper: CustomWrapper })
            .then((result) => {
                console.log('QUOTE' + JSON.stringify(result));
                this.error3 = undefined;
            })
            .catch((error) => {
                this.error3 = error;
                console.error('Œ ERROR => ', JSON.stringify(error));
            });
    }

    async connectedCallback() {
        const messageCallback = response => {
            //console.log('New Event message received: ', JSON.stringify(response));
            this.refresh();
        };
        console.log('Œ Subscription request sent to: ')
        subscribe("/data/Quote_Revenue__ChangeEvent", -1, messageCallback).then(response => {
            console.log(JSON.stringify(response.channel));
            this.subscription1 = response;
        });
        subscribe("/data/Cost__ChangeEvent", -1, messageCallback).then(response => {
            console.log(JSON.stringify(response.channel));
            this.subscription2 = response;
        });
        subscribe("/data/QuoteChangeEvent", -1, messageCallback).then(response => {
            console.log(JSON.stringify(response.channel));
            this.subscription3 = response;
        });

    }

    async disconnectedCallback() {
        unsubscribe(this.subscription1, response => {
            //console.log('unsubscribe() response: ', JSON.stringify(response));
        });
        unsubscribe(this.subscription2, response => {
            //console.log('unsubscribe() response: ', JSON.stringify(response));
        });
        unsubscribe(this.subscription3, response => {
            //console.log('unsubscribe() response: ', JSON.stringify(response));
        });
    }

}