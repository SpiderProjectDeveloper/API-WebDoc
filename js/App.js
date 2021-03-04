//import 'react-app-polyfill/ie11'; 			// Support for ie11
import React, { Component } from 'react';
import SyntaxHighlighter from 'react-syntax-highlighter';
import styles from './../css/app.css'; 
import settings from './Settings';
import texts from './Texts';
import { getCookie, setCookie } from './helpers'
import API from './API';
var htmlReactParser = require('html-react-parser');

class App extends React.Component {
	constructor(props) {
		super(props);
		this.state = { 
			lang: 'ru',
			mainPageTitle: { en:'', ru:'' },
			mainPageText: { en:'', ru:'' },
			apiPageTitle: { en:'', ru:'' },
			examples: null,
      currentExample: null,
      contentId: 'mainPage',
			contentTitle: null,
      contentCode: null,
      contentCodeModule: null,
			contentCodeLang: null,				
			contentCodeDescr: null,				
			contentCodeImg: null,				
			contentCodeProjectFile: null,
			contentCodeProjectShort: null,
			contentCodeResourseLink: null,
			contentCodeResourseText: null,
			contentCodeSourceLink: null
    };

		this.changeLang = this.changeLang.bind(this);
		this.getContent = this.getContent.bind(this);
		this.setCodeContent = this.setCodeContent.bind(this);
	}

	changeLang( e ) {
		for( let i = 0 ; i < settings.langs.length ; i++ ) {
			if( settings.langs[i] === this.state.lang ) {
				let lang = ( i < settings.langs.length-1 ) ? settings.langs[i+1] : settings.langs[0];  		
				this.setState( { lang: lang } );
				setCookie( 'lang', lang );
				if( this.currentExample !== null ) {
						if( 'module' in this.state.currentExample ) { 
								this.getContent( this.state.currentExample );
						}
				}
				break;
			}
		}
	}

	setCodeContent(content, contentCode=null) {
		this.setState({
			contentId: 'code', 
			contentCode: contentCode, 
			contentTitle: content.title[this.state.lang],
			contentCodeDescr: content.descr[this.state.lang], 
			contentCodeLang: ('lang' in content) ? content.lang : null,
			contentCodeModule: ('module' in content) ? content.module : null, 
			contentCodeImg: ('img' in content) ? content.img : null,
			contentCodeProjectFile: ('sprj' in content) ? content.sprj : null,
			contentCodeProjectShort: ('sprj' in content) ? (content.sprj.substr(content.sprj.lastIndexOf("/")+1)) : null,
			contentCodeResourseLink: ('resourseLink' in content) ? content.resourseLink : null,
			contentCodeResourseText: ('resourseText' in content) ? content.resourseText : null,
			contentCodeSourceLink: ('sourceCodeLink' in content) ? content.sourceCodeLink : null,
			currentExample: content 
		});
	}

	getContent(content) {
		if( 'module' in content ) {
			var xhttp = new XMLHttpRequest();
			xhttp.onreadystatechange = function() {
				if (xhttp.readyState == 4 ) {
					if( xhttp.status == 200 ) {
						this.setCodeContent(content, xhttp.responseText );
					} else {
						this.setState( { contentBody: 'Failed to load content...' } );				
					}
				} 	
		  }.bind(this);
			xhttp.open( 'GET', content.module, true );
      xhttp.send();
		} else if( 'sourceCodeLink' in content ) {
			this.setCodeContent(content);
		} else {
			this.setState( { contentId: content.id, currentExample: null } );			
		}
	}

	componentDidMount() {
		let lang = getCookie('lang');
        if( lang !== null ) {
        	this.setState( { lang:lang } );
        }		

		let xhttp = new XMLHttpRequest();
		xhttp.onreadystatechange = function() {
	    	if (xhttp.readyState == 4 ) {
		    	if( xhttp.status == 200 ) {
					let data=null;
					let errorParsingStatusData = false;
					try {
						data = JSON.parse(xhttp.responseText);
					} catch(e) {
						errorParsingStatusData = true;
                    }
					if( !errorParsingStatusData && 'examples' in data ) {
						this.setState( { examples: data.examples } );
						this.setState( { mainPageTitle: data.mainPageTitle, mainPageText: data.mainPageText, apiPageTitle:data.apiPageTitle } );
						return;
					} 
				}
				this.setState( { examples: null } );
            } 
	    }.bind(this);
		xhttp.open( 'GET', 'files/contents.json', true );
    xhttp.send();
  }

	render() {				
		let contentTitle;
		let contentBody;		

		if( this.state.contentId === 'mainPage' ) {
			contentTitle = <div className={styles.contentTitle}>{this.state.mainPageTitle[ this.state.lang ]}</div>
			contentBody = <div className={styles.contentBody}>{htmlReactParser(this.state.mainPageText[ this.state.lang ])}</div>
		} else if ( this.state.contentId === 'API' ) {
			contentTitle = <div className={styles.contentTitle}>{this.state.apiPageTitle[ this.state.lang ]}</div>
			contentBody = <API lang={this.state.lang} />;
		} else if( this.state.contentId === 'code' ) { 	// Code Sample
			contentTitle = <div className={styles.contentTitle}>{this.state.contentTitle}</div>;			
			contentBody = (
				<div>
					<div className={styles.contentCodeDescr}>{htmlReactParser(this.state.contentCodeDescr)}</div>
					{
						(this.state.contentCodeProjectFile !== null ) ? (
							<div className={styles.contentCodeProjectFile}>
								{texts.codeProjectFileDownload[this.state.lang]}
								<a href={this.state.contentCodeProjectFile} download>{this.state.contentCodeProjectShort}</a>
							</div>
						) : null
					}
					{
						(this.state.contentCode !== null ) ? (	
							<div className={styles.contentCode}>
								<SyntaxHighlighter language={this.state.contentCodeLang}>
									{this.state.contentCode}
								</SyntaxHighlighter>
							</div>
						) : null
					}
					{
						(this.state.contentCodeResourseText !== null && this.state.contentCodeResourseLink !== null) ? (
							<div className={styles.contentCodeDescr}>
									<a href={this.state.contentCodeResourseLink} className={styles.contentSourceCodeLink} download>
										{this.state.contentCodeResourseText[this.state.lang]}</a>
							</div>
						) : null
					}
					{
						(this.state.contentCodeSourceLink !== null ) ? (
							<div className={styles.contentCodeDescr}>
									<a href={this.state.contentCodeSourceLink} target={'_blank'} className={styles.contentSourceCodeLink}>
										{settings.textSourceCode[this.state.lang]}</a>
							</div>
						) : null
					}
					{
						(this.state.contentCodeImg !== null ) ? (
							<div>
							<div className={styles.contentCodeOutputTitle}>{texts.codeOutputTitle[this.state.lang]}</div>
							<div className={styles.contentCodeImg}>
								<img src={this.state.contentCodeImg}/>
							</div>
							</div>
						) : null
					}
				</div>
			); 
		} 	

		let examples = [];
		if( this.state.examples !== null ) {
			for( let i = 0 ; i < this.state.examples.length ; i++ ) {
				let ex = this.state.examples[i];
				examples.push( 
					<div key={'divExampleId'+i} className={ (this.state.contentCodeModule === ex.module) ? styles.menuActive : styles.menuItem }
						onClick={ (e) => { this.getContent(ex) } }>{ex.title[this.state.lang]}</div>);
			}
		} else {
			examples = (<div>No examples loaded</div>);
		}

		return( 
			<div>
				<div className={styles.header}>
					<div className={styles.headerControls}>
						<span onClick={this.changeLang}>{ settings.lang[ this.state.lang ] }</span>
					</div>
					<div className={styles.headerTitle}>{ settings.titleText[this.state.lang] }</div>
				</div>
			    <div className={styles.menu}>					
					<div className={ (this.state.contentId === 'mainPage') ? styles.menuActive : styles.menuItem }
						onClick={ (e) => { this.getContent( { id: 'mainPage'} ) } }>{this.state.mainPageTitle[ this.state.lang ]}</div>
					<div className={ (this.state.contentId === 'API') ? styles.menuActive : styles.menuItem }
						onClick={ (e) => { this.getContent( { id: 'API'} ) } }>{this.state.apiPageTitle[ this.state.lang ]}</div>					
					<div className={styles.menuTitle}>{ settings.titleExamples[this.state.lang] }</div>					                                                                         	
					{examples}
			
				</div>
				<div className={styles.content}>
					{contentTitle}
					{contentBody}
					<div className={styles.footer}>
						Powered by <a target={'_blank'} href={'https://reactjs.org'}>{'React'}</a>.
						See the source code and the licence <a href={'https://github.com/SpiderProjectDeveloper/API-WebDoc'}>{'here'}</a>.
					</div>
				</div>
			</div>
    );
	}
}

export default App;