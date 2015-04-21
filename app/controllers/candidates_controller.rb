class CandidatesController < ApplicationController
  require 'uk_postcode'
  require 'json'
  require 'open-uri'
  require 'twitter'

  POLICY_AREAS = [ 'The NHS', 'Economy and taxes', 'Immigration', 'Benefits and pensions', 'Law and order', 'Environment' ]
  PARTY_REPLACE_STRINGS = {
    'Plaid Cymru - The Party of Wales' => 'Plaid Cymru',
    'Scottish National Party (SNP)' => 'Scottish National Party',
  }

  CONSTITUENCY_POLICY = {
    'Birmingham, Yardley' => {
      'The Respect Party' => {
        'The NHS' => [ [ 'To ensure the NHS stays a national institution and is protected from privatisation. Reinstate night time GP callouts. Opposed to TTIP. Increase funding for NHS.' ] ], 
        'Economy and taxes' => [ [ 'Close tax dodging loopholes of corporations and super-rich. Implement a flat rate of tax of 20% for all companies and wage earners. Reduce VAT back to 17.5%' ] ],
        'Immigration' => [ [ 'Respect is in favour of an EU referendum,  and a colour-blind points-based immigration system which is weighted in favour of those coming from Commonwealth countries to which we owe a historic debt.' ] ],
        'Benefits and pensions' => [ [ 'Respect are Anti Austerity and reject the public sector cuts of the three main political parties. We would scrap the bedroom tax and ATOS.' ] ],
        'Law and order' => [ [ 'Opposed to making people work for benefits, and we would protect people’s privacy online. End the war on drugs. Bring justice to CSA survivors' ] ],
        'Environment' => 
        [ [ 'In favour of heavy penalties for fly-tipping. Ensure streets are cleaned weekly. Ensure all households have access to adequate recycling facilities.' ] ]
}},
    'Braintree' => {
      'Independent - Toby Pereira' => {
        'The NHS' => 'Renationalise all parts of the NHS that have been privatised, and commit to keeping the NHS fully nationalised thereafter. Spend more on mental health to reduce longer-term economic and societal costs. Provide more public information to enable and encourage people to better look after their own health.',
        'Economy and taxes' => 'End austerity measures by raising taxes for those who can afford it and clamping down on tax avoidance. Measure economic success in terms of wealth of individuals, particularly the poorest in society, rather than economic growth for its own sake. Reward companies for minimising the wage ratio between the highest and lowest paid employees.',
        'Immigration' => 'Invest more in housing and infrastructure to cope with a growing population. Cooperate internationally to reduce global inequality so that we can create more reciprocal freedom-of-movement agreements with other countries without negative effects for any of the countries involved.',
        'Benefits and pensions' => 'Introduce a Citizen’s Income – a guaranteed regular payment to all citizens regardless of circumstances. This would replace jobseekers’ allowance and would be paid for by changes to income tax brackets. Scrap contributions-based state pensions, so that those who were unable to contribute as much in their working life do not have to suffer the consequences of this in their old age.',
        'Law and order' => 'Have a full review of laws brought in under the umbrella of anti-terrorism legislation that may infringe on our civil liberties. Reserve prison for criminals who pose a physical risk to society, and concentrate more on prevention and rehabilitation rather than punishment for its own sake. Remove the ban on prisoners voting.',
        'Environment' => 'Renationalise energy so that we can commit to spending more on renewable energy and reducing fossil fuel use without worrying about profit. Renationalise public transport and commit to providing a better service to reduce congestion on the roads, carbon emissions and pollution in general.' }},
    'Camberwell and Peckham' => {
      'Trade Unionist and Socialist Coalition' => {
      'The NHS' => 'For a publically owned and democratically run, fully funded, free NHS. Complete opposition to the privatisation of the NHS and to the Private Finance Initiative. Reverse all the privatisation so far. Take the pharmaceutical companies into public ownership. Free prescriptions, dental treatment and eye-tests and lenses.',
      'Economy and taxes' => 'No more public bailouts to the private sector. Progressive taxation of the rich & big corporations. Abolition of VAT. Clamp down on tax avoidance & evasion. Close down tax havens & loopholes. The economy - water, gas, electricity, rail, banks, and all public services like the NHS should be run under democratic public ownership for the benefit of all, not the few.  People before profit.',
      'Immigration' => 'Welcome immigrants and asylum seekers. Oppose nationalism and xenophobia. Support diversity. Oppose racism, fascism and all forms of discrimination. Immigrants are not to blame for the economic crisis. They are here to seek work or refuge. That is why I oppose all immigration controls.',
      'Law and order' => 'Everyone has the right to live a secure, decent and dignified life. Support for equal rights for women, the disabled and LGBT people. Opposition to the restrictions on our civil liberties, such as the right to protest. The police and the security services must be made democratically accountable. End police ‘stop and search’. Support for the right to vote at 16.',
      'Benefits and pensions' => 'We must support all those who cannot work. Benefits must be at a level that affords people a decent life. Abolish the bedroom tax and benefit sanctions. Restore pensions to the level they were in real terms before Thatcher became PM in 1979. Stop the reductions in pensions and the enforced raising of the retirement age.',
      'Environment' => 'Investment in sustainable, low-polluting industry and farming. Opposition to fracking. Investment in renewable energy. To stop climate change we must change the system. Capitalism cares only about making a profit and little for our environment. Taking the economy into democratic common ownership would ensure that people’s needs, including their environmental needs, were taken into account.'}},
    'Southampton, Test' => {
      'Independent - Chris Davis' => {
      'The NHS' => 'The NHS linked to Social Care must be adequately and properly funded. Increased numbers of front line and support staff who are all fully trained and supported should be employed and waste, duplication and bureaucracy cut. A strong NHS linked with social care is fundamental to the country’s wellbeing.',
      'Economy and taxes' => 'We need a minimum wage (£10 per hour) that enables families to live not just survive and to pay their share in tax. A taxation system that is fair, affordable and honest (close the loop holes) at all levels. End austerity measures against the poor. Introduce a tax on banker’s bonuses. Ban (expect under specific circumstances) zero hour contacts. Massive savings could be made by cutting govern.',
      'Immigration' => 'Emigration - We need similar points system to other countries. Migration – EU negotiations must consider infrastructure, housing and jobs. Integration - Those who have decided to make this country their home should learn its language and customs, and more effort needs to be made to welcome those who now legitimately live here. Asylum - The door must be left open for genuine asylum seekers.',
      'Law and order' => 'Review implementation of Universal Credit and abolish the Bedroom Tax. Establish pension and benefit levels that enable people to live rather than just survive. End the sanctions regime that punishes rather than supports and develop ways to enable return to work where appropriate. Introduce means testing for optional benefits (winter heating etc.).',
      'Benefits and pensions' => 'Ensure that profit from crime is confiscated and that penalties reflect the seriousness of the offence and the effect on the victim(s). Everyone, must have access to legal representation with ‘legal aid’ if required. Rights must be universal and not undermined because of colour, gender, sexual orientation or religious persuasion.',
      'Environment' => 'For the sake of future generations we must protect what we have, seeking to find innovative ways to power society without destroying the planet. The development of environmentally friendly means of power generation must be pursued, funded through the profits made by power and fuel companies and permitted by those who will ultimately benefit, (us and our children).'}},
    'Wrexham' => {
      'Independent - Brian Edwards' => {
      'The NHS' => "Stop international aid - except for disasters. Inject a large percentage of the savings directly into the N.H.S to create more nursing staff and G.P's, thus easing the current and alarming burden that exists.",
      'Economy and taxes' => 'A mansion tax implemented on dwellings with a value of over £1.5 million. Tax rate of 60p for anyone earning over £200,00. Inject money from saved overseas aid into our education system. (more trained teachers, updating crumbling school buildings). Drastically reduce student tuition fees.',
      'Immigration' => 'Illegal immigration is more of a problem than immigration itself. Border controls must be increased and vigilance stepped up InputPol4: Look at means-testing such benefits as winter fuel payments and free prescriptions for affluent pensioners. Stop winter fuel allowance for expats living abroad.',
      'Law and order' => 'Implement a UK Bill Of Rights to replace existing Human Rights Act. Introduce a realistic penalty for using a mobile phone whilst driving - £1,000 fine and six-month ban.',
      'Benefits and pensions' => 'Look at means-testing such benefits as winter fuel payments and free prescriptions for affluent pensioners. Stop winter fuel allowance for ex-pats living abroad.',
      'Environment' => 'Environmental matters are important but, regardless, I believe such innovations as fracking will need to be introduced at some time.'}},
    'Newcastle upon Tyne North' => {
      'The North East Party' => {
      'The NHS' => 'A Devolved North East with a NHS North East. Free at the point of use. Free care for the elderly. Local devolved power in regard to management and scrutiny. A devolved system of funding ensuring an integrated service of health care and social services. Public services working ethically with service users and workers and with voluntary, private and community sectors.',
      'Economy and taxes' => 'A reformed local council tax with a 1% level on all houses, subject to a £50,000 threshold. Owner of a £200,000 house would pay £1.500 per year. A regional investment bank and credit union.  A Business Enabling Team-to attract new investment to the area.',
      'Immigration' => 'The North East benefits from individuals who chose to live here and endeavours to ensure equality and diversity for all our communities to live a prosperous and healthy life where participation is encouraged.',
      'Law and order' => 'One regional police authority and a regional commissioner would be sort. Local Community Councils encouraged to participate in local needs and scrutiny.',
      'Benefits and pensions' => 'The North East Party looks to ensure world class services to the people of the North East with free care for the elderly, and public services which are given on a need basis with health and social care integrated to ensure a safe and prosperous future for all. A Devolved North East would follow the policy of the national government but ensure local people participated in voicing local needs.',
      'Environment' => 'The North East Party is keen to encourage the safeguarding of the environment be it air pollution,or waste. And to safeguard wildlife and open care spaces in rural and urban areas. Investment given to rail freight transport to Teesside, and the opening up of railways in regard to Metro links would encourage more public transport and investment in green energy projects for jobs.'}}
}

  PARTY_CONSTANTS = { 
    'Conservative Party' => { 
      'The NHS' => [ [ 'Make GPs available seven days a week by 2020. Recruit 5,000 more doctors. ', 'https://www.conservatives.com/SecuringABetterFuture/GoodServices.aspx' ], [ 'Spend extra £2bn on frontline health services.', 'http://www.bbc.co.uk/news/uk-politics-30265833' ] ],
      'Economy and taxes' => [ [ 'Secure budget surplus by 2019-20. Instead of raising taxes, cut spending, while increasing NHS spending.', 'http://press.conservatives.com/post/98719492085/george-osborne-speech-to-conservative-party' ], [ 'Cut income tax of 30 million people by 2020, by both raising allowance for tax-free income and income tax for high earners.' ] ],
      'Immigration' => [ [ 'Require European jobseekers to leave if they are unemployed after 6 months. Renegotiate the rules for free movement within the EU. Make migrants wait 4 years before claiming certain benefits or social housing.', 'http://press.conservatives.com/post/103802921280/david-cameron-speech-on-immigration' ], [ 'Lower annual net immigration to below 100,000 (currently 243,00).', 'https://www.conservatives.com/Plan/CapWelfareReduceImmigration.aspx' ] ],
      'Benefits and pensions' => [ [ 'Cut the maximum a household can claim yearly from £26,000 to £23,000. Require young people to participate in community projects after six months on Jobseeker\'s Allowance. Freeze increases of benefits for working-age people for two years.', 'http://press.conservatives.com/post/108155759640/david-cameron-britain-living-within-its-means' ] ],
      'Law and order' => [ [ 'Replace Human Rights Act with Bill of Rights to give power to UK courts. New laws to make it easier to collect information about internet activity of suspected criminals. Introduce special orders for groups inciting hatred, and to stop public speech of disruptive individuals.', 'http://press.conservatives.com/post/98799073410/theresa-may-speech-to-conservative-party' ] ],
      'Environment' => [ [ 'No public subsidies for onshore wind power, and planning devolved to local level.', 'http://www.bbc.co.uk/news/uk-politics-27137184' ], [ 'Spend £2.3 billion on 1,400 flood defences schemes in 5 years.', '' ], [ 'The EU manifesto called for carbon emission reduction targets of 40% by 2030, without binding targets for renewables.', 'http://www.conservatives.com/~/media/Files/Downloadable%20Files/MANIFESTO%202014/Large%20Print%20Euro%20Manifesto_English.ashx' ], [ 'Badger culling to be expanded.', 'http://www.bbc.co.uk/news/uk-england-31610260' ] ]
    },
    'Labour Party' => {
      'The NHS' => [ [ 'Ensure that patients get GP appointment within 48 hours. End privatisation of the NHS. Integrate health and social services into whole-person care.', 'http://www.labour.org.uk/issues/detail/gp-48-hour-guarantee' ], [ 'Commit extra £4.5bn to NHS.', 'http://www.nlmanagedservices.co.uk/extra-funding-for-nhs/' ] ],
      'Economy and taxes' => [ [ 'Create budget surplus, with spending cuts and tax changes.', 'http://www.labour.org.uk/manifesto' ], ["Reintroduce 10p lowest tax rate and 50p top tax rate. No raise for NI or VAT. Tax mansions and bankers' bonuses, and remove non-dom status. Freeze energy prices and rail fares, and ban zero-hour contracts.", 'http://press.labour.org.uk/post/74420740121/ed-balls-announces-binding-fiscal-commitment-that' ] ],
      'Immigration' => [ [ 'Reduce low-skilled migration and prevent exploitatio of migrant workers, which undercuts local wages. Hire 1000 more border staff to combat illegal immigration. Ensure migrants will not be able to claim benefits until they have lived in the UK for at least two years.', 'http://www.labour.org.uk/manifesto' ] ],
      'Benefits and pensions' => [ [ 'Increase minimum wage to £8 per hour by 2019. Repeal the bedroom tax.', 'http://www.labour.org.uk/issues/detail/social-security' ], [ 'Double the length of paid paternity leave, and increase statutory paternity pay to £260 a week.', 'http://www.bbc.co.uk/news/uk-politics-31253409' ] ],
      'Law and order' => [ [ 'Give local residents say in crime fighting priorities. Spend more money on frontline policing to prevent reduction in officer numbers. To combat extremism, bring back Control Orders and Prevent strategy.', 'http://www.labour.org.uk/issues/detail/crime-and-policing' ] ],
      'Environment' => [ [ 'Decarbonise UK electricity supply by 2030. Aim for global agreement on zero net carbon emissions by 2050.', 'http://press.labour.org.uk/post/108107596819/climate-change-and-global-poverty-may-not-be-as' ], [ 'Keep forests in public ownership and prioritise public access.', 'http://press.labour.org.uk/post/109924110704/labour-pledges-to-defend-forests-from-future-tory' ], [ 'Review animal welfare laws and end badger cull.', 'http://www.bbc.co.uk/news/uk-politics-31513637' ] ]
    },
    'Liberal Democrats' => { 
      'The NHS' => [ [ '£8bn more funding for the NHS by 2020. Equal care for mental and physical health care patients. Introduce care navigators to help find their way around the system. Repeal those parts of the Health and Social Care Act which would force privatisation of the NHS.', 'http://www.libdems.org.uk/read-the-full-manifesto' ] ],
      'Economy and taxes' => [ [ 'Balance the structural budget deficit by 2017/18 and have debt falling as a percentage of national income. Double innovation spend in our economy.  Devolve more economic decision-making to local areas. Restrict access to non-dom status and end the ability to inherit it. Raise the tax-free Personal Allowance to at least £12,500.', 'http://www.libdems.org.uk/read-the-full-manifesto' ] ],
      'Immigration' => [ [ 'Tighten benefit rules for EU migrants, including reducing payment of Child Benefit to children not resident in the UK. Allow high-skill immigration to support key sectors of the economy. Double the number of inspections on employers to ensure all statutory employment legislation is being respected. End indefinite detention for immigration purposes.', 'http://www.libdems.org.uk/read-the-full-manifesto' ] ],
      'Benefits and pensions' => [ [ 'Provide 15 hours a week of free childcare to the parents of all two-year olds. Introduce a 1% cap on raising of working-age benefits until the budget is balanced, after which they will rise with inflation again. Legislate for the ‘triple lock’ of increasing the State Pension each year by the highest of earnings growth, prices growth or 2.5%.', 'http://www.libdems.org.uk/read-the-full-manifesto' ] ],
      'Law and order' => [ [ 'Reform the House of Lords. Cap political donations to at £10,000 per person each year. Allow crime victims to choose restorative justice. Give legal rights and obligations to cohabiting couples. Extend Freedom of Information laws to cover private companies delivering public services. Pass a Digital Bill of Rights, to define the digital rights of the citizen.', 'http://www.libdems.org.uk/read-the-full-manifesto' ] ],
      'Environment' => [ [ 'Pass a Zero Carbon Britain Act to bring net greenhouse gas emissions to zero by 2050. Expand the Green Investment Bank and set a legally binding decarbonisation target to green our electricity. Establisha statutory waste recycling target of 70%.', 'http://www.libdems.org.uk/read-the-full-manifesto' ] ]
    },
    'Green Party' => {
      'The NHS' => [ [ 'Divert funding form centralised facilities to community healthcare, prevention and health promotion. End privatisation and prescription charges, and create a Medicine Agency that sets drug prices. Ensure NHS funding through earmarked NHS tax.', 'http://policy.greenparty.org.uk/he.html' ] ],
      'Economy and taxes' => [ [ 'Renationalise railways and energy companies.', 'http://greenparty.org.uk/news/2013/02/11/renationalise-rail-says-green-party-leader/' ], [ "Set up citizen's income, an unconditional benefit for basic needs. Stop banks from being able to create new money. Work to end dependency on economic growth.", 'http://policy.greenparty.org.uk/ec.html' ] ],
      'Immigration' => [ [ 'Reduce UK immigration controls over time. Migrants illegally in the UK for over five years will be allowed to remain unless they pose a serious danger to public safety.', 'http://policy.greenparty.org.uk/mg.html' ], [ 'Increase legal rights of asylum seekers.', 'http://policy.greenparty.org.uk/ra.html' ] ],
      'Benefits and pensions' => [ [ 'Reform benefit system with citizen\'s income, an unconditional fixed money transfer.', 'http://greenparty.org.uk/news/2014/11/03/green-party-condemns-three-pronged-government-attack-on-sick-and-disabled/' ], [ 'Before that, ban zero hours contracts, stop current work capability assessments, and provide free social care for over-65s..', 'http://policy.greenparty.org.uk/ec.html' ] ],
      'Law and order' => [ [ 'Design criminal justice policies around restorative justice and prevention, through services such as youth facilities and drug rehabilitation.', 'http://policy.greenparty.org.uk/cj.html' ], [ 'Enact new Bill of Rights that includes direct democracy through Citizen\'s initiatives.', 'http://policy.greenparty.org.uk/pa.html' ] ],
      'Environment' => [ [ 'Reduce UK\'s carbon emission by 90% by 2030, and apply equal per-capita quotas globally. In the long term, require tradeable carbon quotas for energy use.', 'http://policy.greenparty.org.uk/cc.html' ], [ 'Spend £260 billion from energy taxes on green housing and phasing out fossil fuels.', 'http://policy.greenparty.org.uk/cc.html' ], [ 'Localise food production, phase out factory farming.', 'http://policy.greenparty.org.uk/fa.html' ], [ 'Make companies accountable by structuring them democratically.', '' ] ]
    },
    'UK Independence Party (UKIP)' => {
      'The NHS' => [ [ 'Extra £3bn to NHS, funded by leaving EU and middle management cuts. Keep NHS free at point of delivery. Require migrants who have not been in UK for five years to have private medical insurance. Bring back state-enrolled nurses and return powers to matrons.', 'http://www.ukip.org/ukip_pledge_an_extra_3_billion_for_the_nhs' ] ],
      'Economy and taxes' => [ [ 'Increase tax-free personal allowance to £13,500, and reduce tax paid at above £42,000. Abolish inheritance tax, and set up turnover tax on large businesses. Cut the foreign aid budget and EU membership fees.', 'http://www.ukip.org/policies_for_people' ] ],
      'Immigration' => [ [ 'Choose immigrants based on a system of points, reflecting skills needed for work in the country. Apply points system to both EU and non-EU immigrants. Reduce net immigration to 50,000 people a year. Make language skill tests for residence permits harder.', 'http://www.ukip.org/steven_woolfe_ukip_s_ethical_migration_policy' ], [ 'Were the UK to leave the EU people who currently are in the UK legally would not be deported.', '' ] ],
      'Benefits and pensions' => [ [ 'No child benefits for children after the second one, or for children outside of Britain. Repeal the bedroom tax, as it is unfair. No permanent residence for migrants that are unable to support themselves for at least five years.', 'http://www.ukip.org/policies_for_people' ] ],
      'Law and order' => [ [ 'Replace the Human Rights Act with UK Bill of Rights, and withdraw from European Arrest Warrant that coordinates extradition of suspects between European countries. No votes for prisoners, and as a rule prison sentences should be served in their full length.', 'http://www.ukip.org/policies_for_people' ] ],
      'Environment' => [ [ 'Abolish Department of Energy and Climate Change and end green subsidies. Protect green belts by making it easier to build on brownfield sites. Allow large developments to be overturned by signatures of 5% of local electors', 'http://www.ukip.org/policies_for_people' ] ]
    },
    'Scottish National Party' => {
      'The NHS' => [ [ 'For Scottish NHS, increase yearly spending on NHS by more than inflation. Reduce number of senior managers by 25%. Streamline the work of health boards.', 'http://votesnp.com/campaigns/SNP_Manifesto_2011_lowRes.pdf' ] ],
      'Economy and taxes' => [ [ 'Create an international bank tax and limits to industry bonuses. Invest in offshore wind farms.', 'http://www.snp.org/?q=media-centre/news/2014/nov/uk-government-needs-invest-offshore-wind' ], [ 'No to oil drilling and fracking beneath homes, as the Infrastructure Bill would allow.', 'http://www.snp.org/?q=media-centre/news/2014/aug/westminsters-gung-ho-fracking-plans-condemnedo' ] ],
      'Immigration' => [ [ 'Give the devolved Scottish government control over immigration to Scotland. Use a Canadian-style earned citizenship system to attract high-skilled workers.', '' ] ],
      'Benefits and pensions' => [ [ 'In 2010, SNP opposed cuts to in-work benefits, and supported extending paternity leave. It suggested a maximum combined withdrawal rate for benefits, and reforms in employment support allowance and cold weather payments.', 'http://www.politicsresources.net/area/uk/ge10/man/parties/SNP.pdf' ] ],
      'Law and order' => 'No information about SNP policies on rights and crimes yet.',
      'Environment' => [ [ 'Introduced Scottish legislation for reducing carbon emission by 42% by the end of the decade.', 'http://www.snp.org/vision/greener-scotland/climate-change' ], [ 'Meet all Scottish electricity demand with renewables by 2020.', 'http://www.gov.scot/Resource/0043/00439021.pdf' ], [ 'No new nuclear power or dumps in Scotland. Introduce Green Skill Academies, and expand marine carbon sinks', '' ] ]
    },
    'Plaid Cymru' => {
      'The NHS' => [ [ 'For Welsh NHS, recruit 1,000 extra doctors over two terms of government. Offer incentives, improved education, and international recruitment to employ doctors to areas and specilisations where there are shortages. Say no to NHS privatisation.', 'http://www.partyof.wales/uploads/1000_doctors_PDF_Eng_.pdf' ] ],
      'Economy and taxes' => [ [ 'Set living wage as minimum wage. Introduce a 50p tax rate for those earning over £150k a year. Establish publicly owned energy companies and a Welsh Development Bank. Devolve power over institutions such as the Bank of England. Scrap the bedroom tax.', 'https://www.partyof.wales/2015-manifesto/' ] ],
      'Immigration' => [ [ 'Create point-based Welsh Migration Service for migration that meets Welsh needs. Re-introduce a post-study work visa for two years for students who have qualified from Welsh universities. Protect local workers by strengthening the Gangmasters Licensing Act, making it illegal to offer unfair advantage or incentive to migrant workers over local worker.', 'https://www.partyof.wales/2015-manifesto/' ] ],
      'Benefits and pensions' => [ [ 'A new ‘Claim it’ campaign to get unclaimed benefits to those entitled to them. A new single-tier ‘Living Pension’ to help end pensioner poverty. Better use of tax credits to help prevent child poverty in Wales.', 'https://www.partyof.wales/2015-manifesto/' ] ],
      'Law and order' => [ [ 'Rehabilitation and probation as opposed to ineffective short-term sentences that don’t prevent reoffending. Support for the decriminalisation of cannabis. The introduction of Welsh legal jurisdiction to make our own laws.', 'https://www.partyof.wales/2015-manifesto/' ] ],
      'Environment' => [ [ 'Introduce a Climate Change Act for Wales, with carbon targets for 2030 and 2050. Further tests before fracking, and no new opencast mining or nuclear plants. Opposing GMOs in Wales, and supporting the Commno Agricultural Policy.', 'https://www.partyof.wales/2015-manifesto/' ] ]
    },
    'Trade Unionist and Socialist Coalition' => {
      'The NHS' => [ [ 'TUSC supports a high-quality, free National Health Service under democratic public ownership and control.', 'http://www.tusc.org.uk/policy' ] ],
      'Economy and taxes' => [ [ 'Bring banks and finance institutions into genuine public ownership under democratic control, instead of giving huge handouts to the very capitalists who caused the crisis. Tax the rich. For progressive tax on rich corporations and individuals and an end to tax avoidance. Massive investment in environmental projects.', 'http://www.tusc.org.uk/policy' ] ],
      'Immigration' => [ [ 'TUSC welcomes diversity and oppose racism, fascism and discrimination. We defend the right to asylum, call for the repeal the 2014 Immigration Act and all racist immigration controls.', 'http://www.tusc.org.uk/policy' ] ],
      'Benefits and pensions' => [ [ 'Abolish the bedroom tax. Reverse cuts to benefits; for living benefits; end child poverty. Scrap benefit sanctions. Restore the pre-Thatcher real value of pensions. Reverse the increases imposed on the state retirement age, creating jobs for younger people.', 'http://www.tusc.org.uk/policy' ] ],
      'Law and order' => [ [ 'Promote inclusive policies to enable disabled people to participate in, and have equal access to, education, employment, housing, transport and welfare provision. Ensure women have genuinely equal rights and pay. Full equality for LGBT people. Defend our liberties and make police and security democratically accountable. For the right to vote at 16.', 'http://www.tusc.org.uk/policy' ] ],
      'Environment' => [ [ 'Deep cuts in greenhouse gas emissions - otherwise climate change, caused by capitalism, will destroy us. Invest in publicly-owned and controlled renewable energy. Oppose fracking. Move to sustainable, low-pollution industry and farming - stop the pollution that is destroying our environment. No to profit-driven GM technology. Produce for need, not profit, and design goods for reuse and recycling.', 'http://www.tusc.org.uk/policy' ] ]
    },
    'Christian Peoples Alliance' => {
      'The NHS' => [ [ 'Significantly reduce NHS bureaucracy, assist doctors in making the best clinical decisions, & prescribe the best treatment from the GP upwards we want stability in the NHS. we would impose a moratorium on A & E and Hospital closures, and re-configurations, unless there are evidence-based clinical reasons which have the support of the local population and the affected professional staff.' ] ],
      'Economy and taxes' => [ [ 'Ensure fair taxation. Keep a close and critical eye on public sector infrastructure schemes. Phase out housing schemes. Encourage fairer distribution of generated wealth; reform the banking system' ] ],
      'Immigration' => [ [ 'Immigration can be positive for Britain. There are skills and labour we can well use, though we should discourage depleting other countries with greater needs than ours. It is also a privilege to open of education system to overseas students, though monitoring needs to ensure that they return overseas once their agreed stay is over.' ] ],
      'Benefits and pensions' => [ [ 'The CPA aims to increase the minimum wage to £8 per hour as soon possible following consultation. We believe this is a key factor in our drive to care for the poor and reduce poverty. We will make zero hours contracts illegal between ages 21 to 65.' ] ],
      'Law and order' => [ [ 'Unequivocal support for the family. Offer free counselling in the areas of drug and alcohol addictions, which burden individuals and their families. Tackle child poverty by introducing new child tax allowances of £2,373 per child to all parents up to 5 per family. Allow parents who stay at home enhanced child benefit in the early years: early years are basic bonding years.' ] ],
      'Environment' => [ [ 'We will invest in the social ecology of human relationships, especially family life. We shall encourage sustainable fuels, sustainable environment, and sustainable living. We favour a sustained programme of investment energy conservation, localised energy generation, and renewable technologies, as the primary means to boost economic demand, rather than reliance on money/supply solutions.' ] ] },
    'Default' => {
      'The NHS' => 'No information about the NHS for this party or individual yet.',
      'Economy and taxes' => 'No information about economic policy for this party or individual yet.',
      'Immigration' => 'No information about immigration for this party or individual yet.',
      'Benefits and pensions' => 'No information about benefits and pensions for this party or individual yet.',
      'Law and order' => 'No information about rights and crime for this party or individual yet.',
      'Environment' => 'No information about environmental policy for this party or individual yet.'
    }
  }

  TWITTER_LIST = {
    66101 => "aberavon",
    66085 => "aberconwy",
    14398 => "aberdeen-north",
    14399 => "aberdeen-south",
    14400 => "airdrie-and-shotts",
    65730 => "aldershot",
    65773 => "aldridge-brownhills",
    65892 => "altrincham-and-sale-west",
    66103 => "alyn-and-deeside",
    65809 => "amber-valley",
    14401 => "angus",
    66108 => "arfon",
    14402 => "argyll-and-bute",
    65784 => "arundel-and-south-downs",
    65895 => "ashfield",
    65811 => "ashford",
    66056 => "ashton-under-lyne",
    65739 => "aylesbury",
    14403 => "ayr-carrick-and-cumnock",
    66008 => "banbury",
    14404 => "banff-and-buchan",
    65662 => "barking",
    65665 => "barnsley-central",
    66012 => "barnsley-east",
    66006 => "barrow-and-furness",
    65898 => "basildon-and-billericay",
    65623 => "basingstoke",
    65711 => "bassetlaw",
    65798 => "bath",
    65751 => "batley-and-spen",
    65731 => "battersea",
    65687 => "beaconsfield",
    65725 => "beckenham",
    65561 => "bedford",
    66124 => "belfast-east",
    66125 => "belfast-north",
    66126 => "belfast-south",
    66127 => "belfast-west",
    65689 => "bermondsey-and-old-southw",
    65726 => "berwick-upon-tweed",
    14405 => "berwickshire-roxburgh-and",
    65853 => "bethnal-green-and-bow",
    65934 => "beverley-and-holderness",
    65845 => "bexhill-and-battle",
    65611 => "bexleyheath-and-crayford",
    65581 => "birkenhead",
    65931 => "birmingham-edgbaston",
    65667 => "birmingham-erdington",
    65597 => "birmingham-hall-green",
    66072 => "birmingham-hodge-hill",
    65989 => "birmingham-ladywood",
    65966 => "birmingham-northfield",
    66028 => "birmingham-perry-barr",
    65804 => "birmingham-selly-oak",
    65707 => "birmingham-yardley",
    65820 => "bishop-auckland",
    65981 => "blackburn",
    65583 => "blackley-and-broughton",
    65750 => "blackpool-n-and-cleveleys",
    65679 => "blackpool-south",
    66093 => "blaenau-gwent",
    65805 => "blaydon",
    65753 => "blyth-valley",
    65841 => "bognor-regis-and-littleha",
    65628 => "bolsover",
    65646 => "bolton-north-east",
    65712 => "bolton-south-east",
    65738 => "bolton-west",
    65821 => "bootle",
    65969 => "boston-and-skegness",
    66071 => "bosworth",
    65993 => "bournemouth-east",
    65933 => "bournemouth-west",
    65697 => "bracknell",
    65694 => "bradford-east",
    65995 => "bradford-s",
    66036 => "bradford-w",
    65670 => "braintree",
    66088 => "brecon-and-radnorshire",
    66065 => "brent-central",
    65595 => "brent-n",
    65958 => "brentford-and-isleworth",
    65685 => "brentwood-and-ongar",
    66095 => "bridgend",
    65620 => "bridgwater-and-w-somerset",
    66000 => "brigg-and-goole",
    65844 => "brighton-kemptown",
    65787 => "brighton-pavilion",
    65839 => "bristol-e",
    66009 => "bristol-n-w",
    66031 => "bristol-s",
    65574 => "bristol-w",
    65852 => "broadland",
    65954 => "bromley-and-chislehurst",
    65617 => "bromsgrove",
    65639 => "broxbourne",
    65849 => "broxtowe",
    65909 => "buckingham",
    65846 => "burnley",
    65708 => "burton",
    66015 => "bury-n",
    65975 => "bury-s",
    66035 => "bury-st-edmunds",
    66106 => "caerphilly",
    14406 => "caithness-sutherland-and",
    65906 => "calder-valley",
    65913 => "camberwell-and-peckham",
    65826 => "camborne-and-redruth",
    65927 => "cambridge",
    65790 => "cannock-chase",
    65878 => "canterbury",
    66090 => "cardiff-central",
    66120 => "cardiff-n",
    66119 => "cardiff-s-and-penarth",
    66114 => "cardiff-w",
    65929 => "carlisle",
    66089 => "carmarthen-e-and-dinefwr",
    66109 => "carmarthen-w-and-s-pembro",
    65972 => "carshalton-and-wallington",
    65914 => "castle-point",
    14407 => "central-ayrshire",
    65749 => "central-devon",
    65748 => "central-suffolk-and-n-ips",
    66110 => "ceredigion",
    65615 => "charnwood",
    66075 => "chatham-and-aylesford",
    65727 => "cheadle",
    65797 => "chelmsford",
    65818 => "chelsea-and-fulham",
    65946 => "cheltenham",
    65801 => "chesham-and-amersham",
    65980 => "chesterfield",
    65558 => "chichester",
    65721 => "chingford-and-woodford-gr",
    65940 => "chippenham",
    65886 => "chipping-barnet",
    65792 => "chorley",
    65885 => "christchurch",
    65759 => "cities-of-london-and-west",
    65734 => "city-of-chester",
    66021 => "city-of-durham",
    66030 => "clacton",
    66057 => "cleethorpes",
    66121 => "clwyd-s",
    66100 => "clwyd-w",
    14408 => "coatbridge-chryston-and-b",
    65926 => "colchester",
    65835 => "colne-valley",
    65771 => "congleton",
    65893 => "copeland",
    65590 => "corby",
    65636 => "coventry-n-e",
    65575 => "coventry-n-w",
    65877 => "coventry-s",
    65781 => "crawley",
    65572 => "crewe-and-nantwich",
    65603 => "croydon-central",
    65867 => "croydon-n",
    65923 => "croydon-s",
    14409 => "cumbernauld-kilsyth-and-k",
    66105 => "cynon-valley",
    65985 => "dagenham-and-rainham",
    65802 => "darlington",
    66011 => "dartford",
    66025 => "daventry",
    66112 => "delyn",
    65924 => "denton-and-reddish",
    66070 => "derby-n",
    65863 => "derby-s",
    65799 => "derbyshire-dales",
    65723 => "devizes",
    65746 => "dewsbury",
    65553 => "don-valley",
    65621 => "doncaster-central",
    65672 => "doncaster-n",
    65555 => "dover",
    65806 => "dudley-n",
    66054 => "dudley-s",
    65808 => "dulwich-and-w-norwood",
    14410 => "dumfries-and-galloway",
    14411 => "dumfriesshire-clydesdale",
    14412 => "dundee-e",
    14413 => "dundee-w",
    14414 => "dunfermline-and-w-fife",
    66096 => "dwyfor-meirionnydd",
    66128 => "e-antrim",
    65813 => "e-devon",
    14415 => "e-dunbartonshire",
    65573 => "e-ham",
    65569 => "e-hampshire",
    14416 => "e-kilbride-strathaven-and",
    66129 => "e-londonderry",
    14417 => "e-lothian",
    14418 => "e-renfrewshire",
    65856 => "e-surrey",
    65780 => "e-worthing-and-shoreham",
    65979 => "e-yorkshire",
    65755 => "ealing-central-and-acton",
    65701 => "ealing-n",
    65794 => "ealing-southall",
    65823 => "easington",
    65714 => "eastbourne",
    65881 => "eastleigh",
    65756 => "eddisbury",
    14419 => "edinburgh-e",
    14420 => "edinburgh-n-and-leith",
    14422 => "edinburgh-s-w",
    14421 => "edinburgh-s",
    14423 => "edinburgh-w",
    65570 => "edmonton",
    65991 => "ellesmere-port-and-neston",
    65677 => "elmet-and-rothwell",
    65816 => "eltham",
    66050 => "enfield-n",
    65567 => "enfield-southgate",
    66044 => "epping-forest",
    65803 => "epsom-and-ewell",
    65743 => "erewash",
    66023 => "erith-and-thamesmead",
    66062 => "esher-and-walton",
    66033 => "exeter",
    14424 => "falkirk",
    65857 => "fareham",
    65764 => "faversham-and-mid-kent",
    65655 => "feltham-and-heston",
    66130 => "fermanagh-and-s-tyrone",
    65865 => "filton-and-bradley-stoke",
    65938 => "finchley-and-golders-gree",
    65779 => "folkestone-and-hythe",
    66064 => "forest-of-dean",
    66131 => "foyle",
    65955 => "fylde",
    65952 => "gainsborough",
    65900 => "garston-and-halewood",
    65870 => "gateshead",
    65551 => "gedling",
    65864 => "gillingham-and-rainham",
    14425 => "glasgow-central",
    14426 => "glasgow-e",
    14428 => "glasgow-n-e",
    14429 => "glasgow-n-w",
    14427 => "glasgow-n",
    14431 => "glasgow-s-w",
    14430 => "glasgow-s",
    14432 => "glenrothes",
    65996 => "gloucester",
    14433 => "gordon",
    65928 => "gosport",
    66083 => "gower",
    65683 => "grantham-and-stamford",
    65944 => "gravesham",
    65600 => "great-grimsby",
    65627 => "great-yarmouth",
    65837 => "greenwich-and-woolwich",
    65838 => "guildford",
    65550 => "hackney-n-and-stoke-newin",
    65752 => "hackney-s-and-shoreditch",
    65971 => "halesowen-and-rowley-regi",
    65599 => "halifax",
    65671 => "haltemprice-and-howden",
    65915 => "halton",
    65836 => "hammersmith",
    65576 => "hampstead-and-kilburn",
    65675 => "harborough",
    65875 => "harlow",
    65578 => "harrogate-and-knaresborou",
    65650 => "harrow-e",
    65796 => "harrow-w",
    65990 => "hartlepool",
    65674 => "harwich-and-n-essex",
    65640 => "hastings-and-rye",
    65699 => "havant",
    65912 => "hayes-and-harlington",
    65557 => "hazel-grove",
    65967 => "hemel-hempstead",
    66018 => "hemsworth",
    65754 => "hendon",
    65786 => "henley",
    65582 => "hereford-and-s-herefordsh",
    66003 => "hertford-and-stortford",
    65994 => "hertsmere",
    65850 => "hexham",
    65814 => "heywood-and-middleton",
    66052 => "high-peak",
    65724 => "hitchin-and-harpenden",
    65824 => "holborn-and-st-pancras",
    66069 => "hornchurch-and-upminster",
    65883 => "hornsey-and-wood-green",
    65717 => "horsham",
    65947 => "houghton-and-sunderland-s",
    65691 => "hove",
    65624 => "huddersfield",
    65592 => "huntingdon",
    65899 => "hyndburn",
    65630 => "ilford-n",
    65585 => "ilford-s",
    14434 => "inverclyde",
    14435 => "inverness-nairn-badenoch",
    65925 => "ipswich",
    65791 => "isle-of-wight",
    65937 => "islington-n",
    65882 => "islington-s-and-finsbury",
    66097 => "islwyn",
    66026 => "jarrow",
    65871 => "keighley",
    65968 => "kenilworth-and-southam",
    65939 => "kensington",
    66001 => "kettering",
    14436 => "kilmarnock-and-loudoun",
    65778 => "kingston-and-surbiton",
    65709 => "kingston-upon-hull-e",
    65618 => "kingston-upon-hull-n",
    65984 => "kingston-upon-hull-w-and",
    66053 => "kingswood",
    14437 => "kirkcaldy-and-cowdenbeath",
    65869 => "knowsley",
    66132 => "lagan-valley",
    14438 => "lanark-and-hamilton-e",
    65568 => "lancaster-and-fleetwood",
    65765 => "leeds-central",
    65941 => "leeds-e",
    65866 => "leeds-n-e",
    66068 => "leeds-n-w",
    65988 => "leeds-w",
    65807 => "leicester-e",
    65604 => "leicester-s",
    65587 => "leicester-w",
    65978 => "leigh",
    66020 => "lewes",
    66041 => "lewisham-deptford",
    65705 => "lewisham-e",
    65616 => "lewisham-w-and-penge",
    66013 => "leyton-and-wanstead",
    66046 => "lichfield",
    65704 => "lincoln",
    14439 => "linlithgow-and-e-falkirk",
    66066 => "liverpool-riverside",
    65766 => "liverpool-w-derby",
    65970 => "liverpool-walton",
    65644 => "liverpool-wavertree",
    14440 => "livingston",
    66117 => "llanelli",
    65785 => "loughborough",
    65987 => "louth-and-horncastle",
    65690 => "ludlow",
    65887 => "luton-n",
    66080 => "luton-s",
    65896 => "macclesfield",
    65901 => "maidenhead",
    65936 => "maidstone-and-the-weald",
    65645 => "makerfield",
    65661 => "maldon",
    66048 => "manchester-central",
    65834 => "manchester-gorton",
    65819 => "manchester-withington",
    65647 => "mansfield",
    65772 => "meon-valley",
    65932 => "meriden",
    66086 => "merthyr-tydfil-and-rhymne",
    65718 => "mid-bedfordshire",
    66007 => "mid-derbyshire",
    66061 => "mid-dorset-and-n-poole",
    65949 => "mid-norfolk",
    65999 => "mid-sussex",
    66133 => "mid-ulster",
    65888 => "mid-worcestershire",
    65657 => "middlesbrough-s-and-e-cle",
    65998 => "middlesbrough",
    14441 => "midlothian",
    65953 => "milton-keynes-n",
    66076 => "milton-keynes-s",
    66038 => "mitcham-and-morden",
    65693 => "mole-valley",
    66084 => "monmouth",
    66111 => "montgomeryshire",
    14442 => "moray",
    65633 => "morecambe-and-lunesdale",
    65735 => "morley-and-outwood",
    14443 => "motherwell-and-wishaw",
    66135 => "n-antrim",
    14445 => "n-ayrshire-and-arran",
    65602 => "n-cornwall",
    65658 => "n-devon",
    65702 => "n-dorset",
    66136 => "n-down",
    65745 => "n-durham",
    65855 => "n-e-bedfordshire",
    66063 => "n-e-cambridgeshire",
    65676 => "n-e-derbyshire",
    14446 => "n-e-fife",
    65729 => "n-e-hampshire",
    65840 => "n-e-hertfordshire",
    65619 => "n-e-somerset",
    65642 => "n-herefordshire",
    65872 => "n-norfolk",
    66017 => "n-shropshire",
    65817 => "n-somerset",
    65760 => "n-swindon",
    65605 => "n-thanet",
    65720 => "n-tyneside",
    65565 => "n-w-cambridgeshire",
    65859 => "n-w-durham",
    65894 => "n-w-hampshire",
    65776 => "n-w-leicestershire",
    65713 => "n-w-norfolk",
    66024 => "n-warwickshire",
    65822 => "n-wiltshire",
    14444 => "na-h-eileanan-an-iar",
    66082 => "neath",
    65556 => "new-forest-e",
    65815 => "new-forest-w",
    65696 => "newark",
    65862 => "newbury",
    65861 => "newcastle-under-lyme",
    66055 => "newcastle-upon-tyne-centr",
    65594 => "newcastle-upon-tyne-e",
    65664 => "newcastle-upon-tyne-n",
    66094 => "newport-e",
    66099 => "newport-w",
    66134 => "newry-and-armagh",
    65828 => "newton-abbot",
    65918 => "normanton-pontefract-and",
    66059 => "northampton-n",
    65910 => "northampton-s",
    65768 => "norwich-n",
    65634 => "norwich-s",
    65559 => "nottingham-e",
    65643 => "nottingham-n",
    65945 => "nottingham-s",
    65663 => "nuneaton",
    14447 => "ochil-and-s-perthshire",
    66107 => "ogmore",
    65653 => "old-bexley-and-sidcup",
    65903 => "oldham-e-and-saddleworth",
    66022 => "oldham-w-and-royton",
    14448 => "orkney-and-shetland",
    65682 => "orpington",
    66060 => "oxford-e",
    65564 => "oxford-w-and-abingdon",
    14449 => "paisley-and-renfrew-n",
    14450 => "paisley-and-renfrew-s",
    65668 => "pendle",
    66002 => "penistone-and-stocksbridg",
    66081 => "penrith-and-the-border",
    14451 => "perth-and-n-perthshire",
    65649 => "peterborough",
    65974 => "plymouth-moor-view",
    65737 => "plymouth-sutton-and-devon",
    66087 => "pontypridd",
    65860 => "poole",
    65917 => "poplar-and-limehouse",
    65566 => "portsmouth-n",
    66014 => "portsmouth-s",
    66102 => "preseli-pembrokeshire",
    65673 => "preston",
    65637 => "pudsey",
    66045 => "putney",
    65795 => "rayleigh-and-wickford",
    65973 => "reading-e",
    65982 => "reading-w",
    66032 => "redcar",
    65700 => "redditch",
    66005 => "reigate",
    66092 => "rhondda",
    65579 => "ribble-valley",
    65598 => "richmond-park",
    65722 => "richmond-yorks",
    65843 => "rochdale",
    66043 => "rochester-and-strood",
    65584 => "rochford-and-southend-e",
    66077 => "romford",
    65884 => "romsey-and-southampton-n",
    14452 => "ross-skye-and-lochaber",
    66019 => "rossendale-and-darwen",
    65930 => "rother-valley",
    66029 => "rotherham",
    65656 => "rugby",
    65681 => "ruislip-northwood-and-pin",
    65589 => "runnymede-and-weybridge",
    65736 => "rushcliffe",
    14453 => "rutherglen-and-hamilton-w",
    65833 => "rutland-and-melton",
    66137 => "s-antrim",
    65962 => "s-basildon-and-e-thurrock",
    65922 => "s-cambridgeshire",
    65762 => "s-derbyshire",
    65788 => "s-dorset",
    66138 => "s-down",
    65997 => "s-e-cambridgeshire",
    65684 => "s-e-cornwall",
    66051 => "s-holland-and-the-deeping",
    66034 => "s-leicestershire",
    65666 => "s-norfolk",
    65902 => "s-northamptonshire",
    65951 => "s-ribble",
    65719 => "s-shields",
    65943 => "s-staffordshire",
    65614 => "s-suffolk",
    65800 => "s-swindon",
    65829 => "s-thanet",
    65848 => "s-w-bedfordshire",
    65775 => "s-w-devon",
    65596 => "s-w-hertfordshire",
    65652 => "s-w-norfolk",
    65678 => "s-w-surrey",
    65956 => "s-w-wiltshire",
    65654 => "saffron-walden",
    65688 => "salford-and-eccles",
    65889 => "salisbury",
    65891 => "scarborough-and-whitby",
    66027 => "scunthorpe",
    65763 => "sedgefield",
    65706 => "sefton-central",
    65842 => "selby-and-ainsty",
    65698 => "sevenoaks",
    65601 => "sheffield-brightside-and",
    65957 => "sheffield-central",
    65741 => "sheffield-hallam",
    65549 => "sheffield-heeley",
    65793 => "sheffield-s-e",
    65632 => "sherwood",
    65959 => "shipley",
    65563 => "shrewsbury-and-atcham",
    65610 => "sittingbourne-and-sheppey",
    65986 => "skipton-and-ripon",
    65920 => "sleaford-and-n-hykeham",
    65680 => "slough",
    65879 => "solihull",
    65812 => "somerton-and-frome",
    66016 => "southampton-itchen",
    65580 => "southampton-test",
    65876 => "southend-w",
    65728 => "southport",
    65942 => "spelthorne",
    65715 => "st-albans",
    65591 => "st-austell-and-newquay",
    66073 => "st-helens-n",
    65732 => "st-helens-s-and-whiston",
    65854 => "st-ives",
    66067 => "stafford",
    65907 => "staffordshire-moorlands",
    65960 => "stalybridge-and-hyde",
    65571 => "stevenage",
    14454 => "stirling",
    65606 => "stockport",
    65641 => "stockton-n",
    65908 => "stockton-s",
    65710 => "stoke-on-trent-central",
    65783 => "stoke-on-trent-n",
    65770 => "stoke-on-trent-s",
    65950 => "stone",
    65609 => "stourbridge",
    66139 => "strangford",
    65648 => "stratford-on-avon",
    66042 => "streatham",
    65911 => "stretford-and-urmston",
    65858 => "stroud",
    65607 => "suffolk-coastal",
    65586 => "sunderland-central",
    65747 => "surrey-heath",
    66040 => "sutton-and-cheam",
    65703 => "sutton-coldfield",
    66091 => "swansea-e",
    66118 => "swansea-w",
    65880 => "tamworth",
    65964 => "tatton",
    65767 => "taunton-deane",
    65992 => "telford",
    65976 => "tewkesbury",
    65789 => "the-cotswolds",
    65977 => "the-wrekin",
    65686 => "thirsk-and-malton",
    65905 => "thornbury-and-yate",
    65919 => "thurrock",
    65761 => "tiverton-and-honiton",
    65744 => "tonbridge-and-malling",
    65554 => "tooting",
    65692 => "torbay",
    66104 => "torfaen",
    65904 => "torridge-and-w-devon",
    65810 => "totnes",
    66074 => "tottenham",
    65659 => "truro-and-falmouth",
    65660 => "tunbridge-wells",
    65782 => "twickenham",
    65868 => "tynemouth",
    66140 => "upper-bann",
    65613 => "uxbridge-and-s-ruislip",
    66116 => "vale-of-clwyd",
    66098 => "vale-of-glamorgan",
    65825 => "vauxhall",
    14455 => "w-aberdeenshire-and-kinca",
    65983 => "w-bromwich-e",
    66047 => "w-bromwich-west",
    65716 => "w-dorset",
    14456 => "w-dunbartonshire",
    66058 => "w-ham",
    65873 => "w-lancashire",
    65629 => "w-suffolk",
    66141 => "w-tyrone",
    65758 => "w-worcestershire",
    65733 => "wakefield",
    65635 => "wallasey",
    65890 => "walsall-n",
    65832 => "walsall-s",
    65651 => "walthamstow",
    65631 => "wansbeck",
    65638 => "wantage",
    66079 => "warley",
    65874 => "warrington-n",
    65916 => "warrington-s",
    65608 => "warwick-and-leamington",
    66049 => "washington-and-sunderland",
    65626 => "watford",
    66004 => "waveney",
    65961 => "wealden",
    65769 => "weaver-vale",
    65830 => "wellingborough",
    65560 => "wells",
    65740 => "welwyn-hatfield",
    65588 => "wentworth-and-dearne",
    65851 => "westminster-n",
    65963 => "westmorland-and-lonsdale",
    65742 => "weston-super-mare",
    65612 => "wigan",
    65827 => "wimbledon",
    65921 => "winchester",
    65552 => "windsor",
    65847 => "wirral-s",
    65897 => "wirral-w",
    65831 => "witham",
    65622 => "witney",
    66039 => "woking",
    65774 => "wokingham",
    65777 => "wolverhampton-n-e",
    65593 => "wolverhampton-s-e",
    65948 => "wolverhampton-s-w",
    65577 => "worcester",
    65625 => "workington",
    65757 => "worsley-and-eccles-s",
    65562 => "worthing-w",
    66113 => "wrexham",
    66010 => "wycombe",
    65695 => "wyre-and-preston-n",
    66078 => "wyre-forest",
    65669 => "wythenshawe-and-sale-e",
    65935 => "yeovil",
    66115 => "ynys-mon",
    65965 => "york-central",
    66037 => "york-outer"
  }

  CONSTITUENCY_LIST = {
    "aberavon" => [ "Aberavon",66101 ],
    "aberconwy" => [ "Aberconwy",66085 ],
    "aberdeen" => [ "Aberdeen North",14398 ],
    "aberdeen" => [ "Aberdeen South",14399 ],
    "airdrie" => [ "Airdrie and Shotts",14400 ],
    "aldershot" => [ "Aldershot",65730 ],
    "aldridge" => [ "Aldridge-Brownhills",65773 ],
    "altrincham" => [ "Altrincham and Sale West",65892 ],
    "alyn" => [ "Alyn and Deeside",66103 ],
    "amber" => [ "Amber Valley",65809 ],
    "angus" => [ "Angus",14401 ],
    "arfon" => [ "Arfon",66108 ],
    "argyll" => [ "Argyll and Bute",14402 ],
    "arundel" => [ "Arundel and South Downs",65784 ],
    "ashfield" => [ "Ashfield",65895 ],
    "ashford" => [ "Ashford",65811 ],
    "ashton" => [ "Ashton-under-Lyne",66056 ],
    "aylesbury" => [ "Aylesbury",65739 ],
    "ayr-carrick-and-cumnock" => [ "Ayr, Carrick and Cumnock",14403 ],
    "banbury" => [ "Banbury",66008 ],
    "banff-and-buchan" => [ "Banff and Buchan",14404 ],
    "barking" => [ "Barking",65662 ],
    "barnsley-central" => [ "Barnsley Central",65665 ],
    "barnsley-east" => [ "Barnsley East",66012 ],
    "barrow-and-furness" => [ "Barrow and Furness",66006 ],
    "basildon-and-billericay" => [ "Basildon and Billericay",65898 ],
    "basingstoke" => [ "Basingstoke",65623 ],
    "bassetlaw" => [ "Bassetlaw",65711 ],
    "bath" => [ "Bath",65798 ],
    "batley-and-spen" => [ "Batley and Spen",65751 ],
    "battersea" => [ "Battersea",65731 ],
    "beaconsfield" => [ "Beaconsfield",65687 ],
    "beckenham" => [ "Beckenham",65725 ],
    "bedford" => [ "Bedford",65561 ],
    "belfast-east" => [ "Belfast East",66124 ],
    "belfast-north" => [ "Belfast North",66125 ],
    "belfast-south" => [ "Belfast South",66126 ],
    "belfast-west" => [ "Belfast West",66127 ],
    "bermondsey-and-old-southw" => [ "Bermondsey and Old Southwark",65689 ],
    "berwick-upon-tweed" => [ "Berwick-upon-Tweed",65726 ],
    "berwickshire-roxburgh-and" => [ "Berwickshire, Roxburgh and Selkirk",14405 ],
    "bethnal-green-and-bow" => [ "Bethnal Green and Bow",65853 ],
    "beverley-and-holderness" => [ "Beverley and Holderness",65934 ],
    "bexhill-and-battle" => [ "Bexhill and Battle",65845 ],
    "bexleyheath-and-crayford" => [ "Bexleyheath and Crayford",65611 ],
    "birkenhead" => [ "Birkenhead",65581 ],
    "birmingham-edgbaston" => [ "Birmingham, Edgbaston",65931 ],
    "birmingham-erdington" => [ "Birmingham, Erdington",65667 ],
    "birmingham-hall-green" => [ "Birmingham, Hall Green",65597 ],
    "birmingham-hodge-hill" => [ "Birmingham, Hodge Hill",66072 ],
    "birmingham-ladywood" => [ "Birmingham, Ladywood",65989 ],
    "birmingham-northfield" => [ "Birmingham, Northfield",65966 ],
    "birmingham-perry-barr" => [ "Birmingham, Perry Barr",66028 ],
    "birmingham-selly-oak" => [ "Birmingham, Selly Oak",65804 ],
    "birmingham-yardley" => [ "Birmingham, Yardley",65707 ],
    "bishop-auckland" => [ "Bishop Auckland",65820 ],
    "blackburn" => [ "Blackburn",65981 ],
    "blackley-and-broughton" => [ "Blackley and Broughton",65583 ],
    "blackpool-n-and-cleveleys" => [ "Blackpool North and Cleveleys",65750 ],
    "blackpool-south" => [ "Blackpool South",65679 ],
    "blaenau-gwent" => [ "Blaenau Gwent",66093 ],
    "blaydon" => [ "Blaydon",65805 ],
    "blyth-valley" => [ "Blyth Valley",65753 ],
    "bognor-regis-and-littleha" => [ "Bognor Regis and Littlehampton",65841 ],
    "bolsover" => [ "Bolsover",65628 ],
    "bolton-north-east" => [ "Bolton North East",65646 ],
    "bolton-south-east" => [ "Bolton South East",65712 ],
    "bolton-west" => [ "Bolton West",65738 ],
    "bootle" => [ "Bootle",65821 ],
    "boston-and-skegness" => [ "Boston and Skegness",65969 ],
    "bosworth" => [ "Bosworth",66071 ],
    "bournemouth-east" => [ "Bournemouth East",65993 ],
    "bournemouth-west" => [ "Bournemouth West",65933 ],
    "bracknell" => [ "Bracknell",65697 ],
    "bradford-east" => [ "Bradford East",65694 ],
    "bradford-s" => [ "Bradford South",65995 ],
    "bradford-w" => [ "Bradford West",66036 ],
    "braintree" => [ "Braintree",65670 ],
    "brecon-and-radnorshire" => [ "Brecon and Radnorshire",66088 ],
    "brent-central" => [ "Brent Central",66065 ],
    "brent-n" => [ "Brent North",65595 ],
    "brentford-and-isleworth" => [ "Brentford and Isleworth",65958 ],
    "brentwood-and-ongar" => [ "Brentwood and Ongar",65685 ],
    "bridgend" => [ "Bridgend",66095 ],
    "bridgwater-and-w-somerset" => [ "Bridgwater and West Somerset",65620 ],
    "brigg-and-goole" => [ "Brigg and Goole",66000 ],
    "brighton-kemptown" => [ "Brighton, Kemptown",65844 ],
    "brighton-pavilion" => [ "Brighton, Pavilion",65787 ],
    "bristol-e" => [ "Bristol East",65839 ],
    "bristol-n-w" => [ "Bristol North West",66009 ],
    "bristol-s" => [ "Bristol South",66031 ],
    "bristol-w" => [ "Bristol West",65574 ],
    "broadland" => [ "Broadland",65852 ],
    "bromley-and-chislehurst" => [ "Bromley and Chislehurst",65954 ],
    "bromsgrove" => [ "Bromsgrove",65617 ],
    "broxbourne" => [ "Broxbourne",65639 ],
    "broxtowe" => [ "Broxtowe",65849 ],
    "buckingham" => [ "Buckingham",65909 ],
    "burnley" => [ "Burnley",65846 ],
    "burton" => [ "Burton",65708 ],
    "bury-n" => [ "Bury North",66015 ],
    "bury-s" => [ "Bury South",65975 ],
    "bury-st-edmunds" => [ "Bury St Edmunds",66035 ],
    "caerphilly" => [ "Caerphilly",66106 ],
    "caithness-sutherland-and" => [ "Caithness, Sutherland and Easter Ross",14406 ],
    "calder-valley" => [ "Calder Valley",65906 ],
    "camberwell-and-peckham" => [ "Camberwell and Peckham",65913 ],
    "camborne-and-redruth" => [ "Camborne and Redruth",65826 ],
    "cambridge" => [ "Cambridge",65927 ],
    "cannock-chase" => [ "Cannock Chase",65790 ],
    "canterbury" => [ "Canterbury",65878 ],
    "cardiff-central" => [ "Cardiff Central",66090 ],
    "cardiff-n" => [ "Cardiff North",66120 ],
    "cardiff-s-and-penarth" => [ "Cardiff South and Penarth",66119 ],
    "cardiff-w" => [ "Cardiff West",66114 ],
    "carlisle" => [ "Carlisle",65929 ],
    "carmarthen-e-and-dinefwr" => [ "Carmarthen East and Dinefwr",66089 ],
    "carmarthen-w-and-s-pembro" => [ "Carmarthen West and South Pembrokeshire",66109 ],
    "carshalton-and-wallington" => [ "Carshalton and Wallington",65972 ],
    "castle-point" => [ "Castle Point",65914 ],
    "central-ayrshire" => [ "Central Ayrshire",14407 ],
    "central-devon" => [ "Central Devon",65749 ],
    "central-suffolk-and-n-ips" => [ "Central Suffolk and North Ipswich",65748 ],
    "ceredigion" => [ "Ceredigion",66110 ],
    "charnwood" => [ "Charnwood",65615 ],
    "chatham-and-aylesford" => [ "Chatham and Aylesford",66075 ],
    "cheadle" => [ "Cheadle",65727 ],
    "chelmsford" => [ "Chelmsford",65797 ],
    "chelsea-and-fulham" => [ "Chelsea and Fulham",65818 ],
    "cheltenham" => [ "Cheltenham",65946 ],
    "chesham-and-amersham" => [ "Chesham and Amersham",65801 ],
    "chesterfield" => [ "Chesterfield",65980 ],
    "chichester" => [ "Chichester",65558 ],
    "chingford-and-woodford-gr" => [ "Chingford and Woodford Green",65721 ],
    "chippenham" => [ "Chippenham",65940 ],
    "chipping-barnet" => [ "Chipping Barnet",65886 ],
    "chorley" => [ "Chorley",65792 ],
    "christchurch" => [ "Christchurch",65885 ],
    "cities-of-london-and-west" => [ "Cities of London and Westminster",65759 ],
    "city-of-chester" => [ "City of Chester",65734 ],
    "city-of-durham" => [ "City of Durham",66021 ],
    "clacton" => [ "Clacton",66030 ],
    "cleethorpes" => [ "Cleethorpes",66057 ],
    "clwyd-s" => [ "Clwyd South",66121 ],
    "clwyd-w" => [ "Clwyd West",66100 ],
    "coatbridge-chryston-and-b" => [ "Coatbridge, Chryston and Bellshill",14408 ],
    "colchester" => [ "Colchester",65926 ],
    "colne-valley" => [ "Colne Valley",65835 ],
    "congleton" => [ "Congleton",65771 ],
    "copeland" => [ "Copeland",65893 ],
    "corby" => [ "Corby",65590 ],
    "coventry-n-e" => [ "Coventry North East",65636 ],
    "coventry-n-w" => [ "Coventry North West",65575 ],
    "coventry-s" => [ "Coventry South",65877 ],
    "crawley" => [ "Crawley",65781 ],
    "crewe-and-nantwich" => [ "Crewe and Nantwich",65572 ],
    "croydon-central" => [ "Croydon Central",65603 ],
    "croydon-n" => [ "Croydon North",65867 ],
    "croydon-s" => [ "Croydon South",65923 ],
    "cumbernauld-kilsyth-and-k" => [ "Cumbernauld, Kilsyth and Kirkintilloch East",14409 ],
    "cynon-valley" => [ "Cynon Valley",66105 ],
    "dagenham-and-rainham" => [ "Dagenham and Rainham",65985 ],
    "darlington" => [ "Darlington",65802 ],
    "dartford" => [ "Dartford",66011 ],
    "daventry" => [ "Daventry",66025 ],
    "delyn" => [ "Delyn",66112 ],
    "denton-and-reddish" => [ "Denton and Reddish",65924 ],
    "derby-n" => [ "Derby North",66070 ],
    "derby-s" => [ "Derby South",65863 ],
    "derbyshire-dales" => [ "Derbyshire Dales",65799 ],
    "devizes" => [ "Devizes",65723 ],
    "dewsbury" => [ "Dewsbury",65746 ],
    "don-valley" => [ "Don Valley",65553 ],
    "doncaster-central" => [ "Doncaster Central",65621 ],
    "doncaster-n" => [ "Doncaster North",65672 ],
    "dover" => [ "Dover",65555 ],
    "dudley-n" => [ "Dudley North",65806 ],
    "dudley-s" => [ "Dudley South",66054 ],
    "dulwich-and-w-norwood" => [ "Dulwich and West Norwood",65808 ],
    "dumfries-and-galloway" => [ "Dumfries and Galloway",14410 ],
    "dumfriesshire-clydesdale" => [ "Dumfriesshire, Clydesdale and Tweeddale",14411 ],
    "dundee-e" => [ "Dundee East",14412 ],
    "dundee-w" => [ "Dundee West",14413 ],
    "dunfermline-and-w-fife" => [ "Dunfermline and West Fife",14414 ],
    "dwyfor-meirionnydd" => [ "Dwyfor Meirionnydd",66096 ],
    "e-antrim" => [ "East Antrim",66128 ],
    "e-devon" => [ "East Devon",65813 ],
    "e-dunbartonshire" => [ "East Dunbartonshire",14415 ],
    "e-ham" => [ "East Ham",65573 ],
    "e-hampshire" => [ "East Hampshire",65569 ],
    "e-kilbride-strathaven-and" => [ "East Kilbride, Strathaven and Lesmahagow",14416 ],
    "e-londonderry" => [ "East Londonderry",66129 ],
    "e-lothian" => [ "East Lothian",14417 ],
    "e-renfrewshire" => [ "East Renfrewshire",14418 ],
    "e-surrey" => [ "East Surrey",65856 ],
    "e-worthing-and-shoreham" => [ "East Worthing and Shoreham",65780 ],
    "e-yorkshire" => [ "East Yorkshire",65979 ],
    "ealing-central-and-acton" => [ "Ealing Central and Acton",65755 ],
    "ealing-n" => [ "Ealing North",65701 ],
    "ealing-southall" => [ "Ealing, Southall",65794 ],
    "easington" => [ "Easington",65823 ],
    "eastbourne" => [ "Eastbourne",65714 ],
    "eastleigh" => [ "Eastleigh",65881 ],
    "eddisbury" => [ "Eddisbury",65756 ],
    "edinburgh-e" => [ "Edinburgh East",14419 ],
    "edinburgh-n-and-leith" => [ "Edinburgh North and Leith",14420 ],
    "edinburgh-s-w" => [ "Edinburgh South West",14422 ],
    "edinburgh-s" => [ "Edinburgh South",14421 ],
    "edinburgh-w" => [ "Edinburgh West",14423 ],
    "edmonton" => [ "Edmonton",65570 ],
    "ellesmere-port-and-neston" => [ "Ellesmere Port and Neston",65991 ],
    "elmet-and-rothwell" => [ "Elmet and Rothwell",65677 ],
    "eltham" => [ "Eltham",65816 ],
    "enfield-n" => [ "Enfield North",66050 ],
    "enfield-southgate" => [ "Enfield, Southgate",65567 ],
    "epping-forest" => [ "Epping Forest",66044 ],
    "epsom-and-ewell" => [ "Epsom and Ewell",65803 ],
    "erewash" => [ "Erewash",65743 ],
    "erith-and-thamesmead" => [ "Erith and Thamesmead",66023 ],
    "esher-and-walton" => [ "Esher and Walton",66062 ],
    "exeter" => [ "Exeter",66033 ],
    "falkirk" => [ "Falkirk",14424 ],
    "fareham" => [ "Fareham",65857 ],
    "faversham-and-mid-kent" => [ "Faversham and Mid Kent",65764 ],
    "feltham-and-heston" => [ "Feltham and Heston",65655 ],
    "fermanagh-and-s-tyrone" => [ "Fermanagh and South Tyrone",66130 ],
    "filton-and-bradley-stoke" => [ "Filton and Bradley Stoke",65865 ],
    "finchley-and-golders-gree" => [ "Finchley and Golders Green",65938 ],
    "folkestone-and-hythe" => [ "Folkestone and Hythe",65779 ],
    "forest-of-dean" => [ "Forest of Dean",66064 ],
    "foyle" => [ "Foyle",66131 ],
    "fylde" => [ "Fylde",65955 ],
    "gainsborough" => [ "Gainsborough",65952 ],
    "garston-and-halewood" => [ "Garston and Halewood",65900 ],
    "gateshead" => [ "Gateshead",65870 ],
    "gedling" => [ "Gedling",65551 ],
    "gillingham-and-rainham" => [ "Gillingham and Rainham",65864 ],
    "glasgow-central" => [ "Glasgow Central",14425 ],
    "glasgow-e" => [ "Glasgow East",14426 ],
    "glasgow-n-e" => [ "Glasgow North East",14428 ],
    "glasgow-n-w" => [ "Glasgow North West",14429 ],
    "glasgow-n" => [ "Glasgow North",14427 ],
    "glasgow-s-w" => [ "Glasgow South West",14431 ],
    "glasgow-s" => [ "Glasgow South",14430 ],
    "glenrothes" => [ "Glenrothes",14432 ],
    "gloucester" => [ "Gloucester",65996 ],
    "gordon" => [ "Gordon",14433 ],
    "gosport" => [ "Gosport",65928 ],
    "gower" => [ "Gower",66083 ],
    "grantham-and-stamford" => [ "Grantham and Stamford",65683 ],
    "gravesham" => [ "Gravesham",65944 ],
    "great-grimsby" => [ "Great Grimsby",65600 ],
    "great-yarmouth" => [ "Great Yarmouth",65627 ],
    "greenwich-and-woolwich" => [ "Greenwich and Woolwich",65837 ],
    "guildford" => [ "Guildford",65838 ],
    "hackney-n-and-stoke-newin" => [ "Hackney North and Stoke Newington",65550 ],
    "hackney-s-and-shoreditch" => [ "Hackney South and Shoreditch",65752 ],
    "halesowen-and-rowley-regi" => [ "Halesowen and Rowley Regis",65971 ],
    "halifax" => [ "Halifax",65599 ],
    "haltemprice-and-howden" => [ "Haltemprice and Howden",65671 ],
    "halton" => [ "Halton",65915 ],
    "hammersmith" => [ "Hammersmith",65836 ],
    "hampstead-and-kilburn" => [ "Hampstead and Kilburn",65576 ],
    "harborough" => [ "Harborough",65675 ],
    "harlow" => [ "Harlow",65875 ],
    "harrogate-and-knaresborou" => [ "Harrogate and Knaresborough",65578 ],
    "harrow-e" => [ "Harrow East",65650 ],
    "harrow-w" => [ "Harrow West",65796 ],
    "hartlepool" => [ "Hartlepool",65990 ],
    "harwich-and-n-essex" => [ "Harwich and North Essex",65674 ],
    "hastings-and-rye" => [ "Hastings and Rye",65640 ],
    "havant" => [ "Havant",65699 ],
    "hayes-and-harlington" => [ "Hayes and Harlington",65912 ],
    "hazel-grove" => [ "Hazel Grove",65557 ],
    "hemel-hempstead" => [ "Hemel Hempstead",65967 ],
    "hemsworth" => [ "Hemsworth",66018 ],
    "hendon" => [ "Hendon",65754 ],
    "henley" => [ "Henley",65786 ],
    "hereford-and-s-herefordsh" => [ "Hereford and South Herefordshire",65582 ],
    "hertford-and-stortford" => [ "Hertford and Stortford",66003 ],
    "hertsmere" => [ "Hertsmere",65994 ],
    "hexham" => [ "Hexham",65850 ],
    "heywood-and-middleton" => [ "Heywood and Middleton",65814 ],
    "high-peak" => [ "High Peak",66052 ],
    "hitchin-and-harpenden" => [ "Hitchin and Harpenden",65724 ],
    "holborn-and-st-pancras" => [ "Holborn and St Pancras",65824 ],
    "hornchurch-and-upminster" => [ "Hornchurch and Upminster",66069 ],
    "hornsey-and-wood-green" => [ "Hornsey and Wood Green",65883 ],
    "horsham" => [ "Horsham",65717 ],
    "houghton-and-sunderland-s" => [ "Houghton and Sunderland South",65947 ],
    "hove" => [ "Hove",65691 ],
    "huddersfield" => [ "Huddersfield",65624 ],
    "huntingdon" => [ "Huntingdon",65592 ],
    "hyndburn" => [ "Hyndburn",65899 ],
    "ilford-n" => [ "Ilford North",65630 ],
    "ilford-s" => [ "Ilford South",65585 ],
    "inverclyde" => [ "Inverclyde",14434 ],
    "inverness-nairn-badenoch" => [ "Inverness, Nairn, Badenoch and Strathspey",14435 ],
    "ipswich" => [ "Ipswich",65925 ],
    "isle-of-wight" => [ "Isle of Wight",65791 ],
    "islington-n" => [ "Islington North",65937 ],
    "islington-s-and-finsbury" => [ "Islington South and Finsbury",65882 ],
    "islwyn" => [ "Islwyn",66097 ],
    "jarrow" => [ "Jarrow",66026 ],
    "keighley" => [ "Keighley",65871 ],
    "kenilworth-and-southam" => [ "Kenilworth and Southam",65968 ],
    "kensington" => [ "Kensington",65939 ],
    "kettering" => [ "Kettering",66001 ],
    "kilmarnock-and-loudoun" => [ "Kilmarnock and Loudoun",14436 ],
    "kingston-and-surbiton" => [ "Kingston and Surbiton",65778 ],
    "kingston-upon-hull-e" => [ "Kingston upon Hull East",65709 ],
    "kingston-upon-hull-n" => [ "Kingston upon Hull North",65618 ],
    "kingston-upon-hull-w-and" => [ "Kingston upon Hull West and Hessle",65984 ],
    "kingswood" => [ "Kingswood",66053 ],
    "kirkcaldy-and-cowdenbeath" => [ "Kirkcaldy and Cowdenbeath",14437 ],
    "knowsley" => [ "Knowsley",65869 ],
    "lagan-valley" => [ "Lagan Valley",66132 ],
    "lanark-and-hamilton-e" => [ "Lanark and Hamilton East",14438 ],
    "lancaster-and-fleetwood" => [ "Lancaster and Fleetwood",65568 ],
    "leeds-central" => [ "Leeds Central",65765 ],
    "leeds-e" => [ "Leeds East",65941 ],
    "leeds-n-e" => [ "Leeds North East",65866 ],
    "leeds-n-w" => [ "Leeds North West",66068 ],
    "leeds-w" => [ "Leeds West",65988 ],
    "leicester-e" => [ "Leicester East",65807 ],
    "leicester-s" => [ "Leicester South",65604 ],
    "leicester-w" => [ "Leicester West",65587 ],
    "leigh" => [ "Leigh",65978 ],
    "lewes" => [ "Lewes",66020 ],
    "lewisham-deptford" => [ "Lewisham, Deptford",66041 ],
    "lewisham-e" => [ "Lewisham East",65705 ],
    "lewisham-w-and-penge" => [ "Lewisham West and Penge",65616 ],
    "leyton-and-wanstead" => [ "Leyton and Wanstead",66013 ],
    "lichfield" => [ "Lichfield",66046 ],
    "lincoln" => [ "Lincoln",65704 ],
    "linlithgow-and-e-falkirk" => [ "Linlithgow and East Falkirk",14439 ],
    "liverpool-riverside" => [ "Liverpool, Riverside",66066 ],
    "liverpool-w-derby" => [ "Liverpool, West Derby",65766 ],
    "liverpool-walton" => [ "Liverpool, Walton",65970 ],
    "liverpool-wavertree" => [ "Liverpool, Wavertree",65644 ],
    "livingston" => [ "Livingston",14440 ],
    "llanelli" => [ "Llanelli",66117 ],
    "loughborough" => [ "Loughborough",65785 ],
    "louth-and-horncastle" => [ "Louth and Horncastle",65987 ],
    "ludlow" => [ "Ludlow",65690 ],
    "luton-n" => [ "Luton North",65887 ],
    "luton-s" => [ "Luton South",66080 ],
    "macclesfield" => [ "Macclesfield",65896 ],
    "maidenhead" => [ "Maidenhead",65901 ],
    "maidstone-and-the-weald" => [ "Maidstone and The Weald",65936 ],
    "makerfield" => [ "Makerfield",65645 ],
    "maldon" => [ "Maldon",65661 ],
    "manchester-central" => [ "Manchester Central",66048 ],
    "manchester-gorton" => [ "Manchester, Gorton",65834 ],
    "manchester-withington" => [ "Manchester, Withington",65819 ],
    "mansfield" => [ "Mansfield",65647 ],
    "meon-valley" => [ "Meon Valley",65772 ],
    "meriden" => [ "Meriden",65932 ],
    "merthyr-tydfil-and-rhymne" => [ "Merthyr Tydfil and Rhymney",66086 ],
    "mid-bedfordshire" => [ "Mid Bedfordshire",65718 ],
    "mid-derbyshire" => [ "Mid Derbyshire",66007 ],
    "mid-dorset-and-n-poole" => [ "Mid Dorset and North Poole",66061 ],
    "mid-norfolk" => [ "Mid Norfolk",65949 ],
    "mid-sussex" => [ "Mid Sussex",65999 ],
    "mid-ulster" => [ "Mid Ulster",66133 ],
    "mid-worcestershire" => [ "Mid Worcestershire",65888 ],
    "middlesbrough-s-and-e-cle" => [ "Middlesbrough South and East Cleveland",65657 ],
    "middlesbrough" => [ "Middlesbrough",65998 ],
    "midlothian" => [ "Midlothian",14441 ],
    "milton-keynes-n" => [ "Milton Keynes North",65953 ],
    "milton-keynes-s" => [ "Milton Keynes South",66076 ],
    "mitcham-and-morden" => [ "Mitcham and Morden",66038 ],
    "mole-valley" => [ "Mole Valley",65693 ],
    "monmouth" => [ "Monmouth",66084 ],
    "montgomeryshire" => [ "Montgomeryshire",66111 ],
    "moray" => [ "Moray",14442 ],
    "morecambe-and-lunesdale" => [ "Morecambe and Lunesdale",65633 ],
    "morley-and-outwood" => [ "Morley and Outwood",65735 ],
    "motherwell-and-wishaw" => [ "Motherwell and Wishaw",14443 ],
    "n-antrim" => [ "North Antrim",66135 ],
    "n-ayrshire-and-arran" => [ "North Ayrshire and Arran",14445 ],
    "n-cornwall" => [ "North Cornwall",65602 ],
    "n-devon" => [ "North Devon",65658 ],
    "n-dorset" => [ "North Dorset",65702 ],
    "n-down" => [ "North Down",66136 ],
    "n-durham" => [ "North Durham",65745 ],
    "n-e-bedfordshire" => [ "North East Bedfordshire",65855 ],
    "n-e-cambridgeshire" => [ "North East Cambridgeshire",66063 ],
    "n-e-derbyshire" => [ "North East Derbyshire",65676 ],
    "n-e-fife" => [ "North East Fife",14446 ],
    "n-e-hampshire" => [ "North East Hampshire",65729 ],
    "n-e-hertfordshire" => [ "North East Hertfordshire",65840 ],
    "n-e-somerset" => [ "North East Somerset",65619 ],
    "n-herefordshire" => [ "North Herefordshire",65642 ],
    "n-norfolk" => [ "North Norfolk",65872 ],
    "n-shropshire" => [ "North Shropshire",66017 ],
    "n-somerset" => [ "North Somerset",65817 ],
    "n-swindon" => [ "North Swindon",65760 ],
    "n-thanet" => [ "North Thanet",65605 ],
    "n-tyneside" => [ "North Tyneside",65720 ],
    "n-w-cambridgeshire" => [ "North West Cambridgeshire",65565 ],
    "n-w-durham" => [ "North West Durham",65859 ],
    "n-w-hampshire" => [ "North West Hampshire",65894 ],
    "n-w-leicestershire" => [ "North West Leicestershire",65776 ],
    "n-w-norfolk" => [ "North West Norfolk",65713 ],
    "n-warwickshire" => [ "North Warwickshire",66024 ],
    "n-wiltshire" => [ "North Wiltshire",65822 ],
    "na-h-eileanan-an-iar" => [ "Na h-Eileanan an Iar",14444 ],
    "neath" => [ "Neath",66082 ],
    "new-forest-e" => [ "New Forest East",65556 ],
    "new-forest-w" => [ "New Forest West",65815 ],
    "newark" => [ "Newark",65696 ],
    "newbury" => [ "Newbury",65862 ],
    "newcastle-under-lyme" => [ "Newcastle-under-Lyme",65861 ],
    "newcastle-upon-tyne-centr" => [ "Newcastle upon Tyne Central",66055 ],
    "newcastle-upon-tyne-e" => [ "Newcastle upon Tyne East",65594 ],
    "newcastle-upon-tyne-n" => [ "Newcastle upon Tyne North",65664 ],
    "newport-e" => [ "Newport East",66094 ],
    "newport-w" => [ "Newport West",66099 ],
    "newry-and-armagh" => [ "Newry and Armagh",66134 ],
    "newton-abbot" => [ "Newton Abbot",65828 ],
    "normanton-pontefract-and" => [ "Normanton, Pontefract and Castleford",65918 ],
    "northampton-n" => [ "Northampton North",66059 ],
    "northampton-s" => [ "Northampton South",65910 ],
    "norwich-n" => [ "Norwich North",65768 ],
    "norwich-s" => [ "Norwich South",65634 ],
    "nottingham-e" => [ "Nottingham East",65559 ],
    "nottingham-n" => [ "Nottingham North",65643 ],
    "nottingham-s" => [ "Nottingham South",65945 ],
    "nuneaton" => [ "Nuneaton",65663 ],
    "ochil-and-s-perthshire" => [ "Ochil and South Perthshire",14447 ],
    "ogmore" => [ "Ogmore",66107 ],
    "old-bexley-and-sidcup" => [ "Old Bexley and Sidcup",65653 ],
    "oldham-e-and-saddleworth" => [ "Oldham East and Saddleworth",65903 ],
    "oldham-w-and-royton" => [ "Oldham West and Royton",66022 ],
    "orkney-and-shetland" => [ "Orkney and Shetland",14448 ],
    "orpington" => [ "Orpington",65682 ],
    "oxford-e" => [ "Oxford East",66060 ],
    "oxford-w-and-abingdon" => [ "Oxford West and Abingdon",65564 ],
    "paisley-and-renfrew-n" => [ "Paisley and Renfrewshire North",14449 ],
    "paisley-and-renfrew-s" => [ "Paisley and Renfrewshire South",14450 ],
    "pendle" => [ "Pendle",65668 ],
    "penistone-and-stocksbridg" => [ "Penistone and Stocksbridge",66002 ],
    "penrith-and-the-border" => [ "Penrith and The Border",66081 ],
    "perth-and-n-perthshire" => [ "Perth and North Perthshire",14451 ],
    "peterborough" => [ "Peterborough",65649 ],
    "plymouth-moor-view" => [ "Plymouth, Moor View",65974 ],
    "plymouth-sutton-and-devon" => [ "Plymouth, Sutton and Devonport",65737 ],
    "pontypridd" => [ "Pontypridd",66087 ],
    "poole" => [ "Poole",65860 ],
    "poplar-and-limehouse" => [ "Poplar and Limehouse",65917 ],
    "portsmouth-n" => [ "Portsmouth North",65566 ],
    "portsmouth-s" => [ "Portsmouth South",66014 ],
    "preseli-pembrokeshire" => [ "Preseli Pembrokeshire",66102 ],
    "preston" => [ "Preston",65673 ],
    "pudsey" => [ "Pudsey",65637 ],
    "putney" => [ "Putney",66045 ],
    "rayleigh-and-wickford" => [ "Rayleigh and Wickford",65795 ],
    "reading-e" => [ "Reading East",65973 ],
    "reading-w" => [ "Reading West",65982 ],
    "redcar" => [ "Redcar",66032 ],
    "redditch" => [ "Redditch",65700 ],
    "reigate" => [ "Reigate",66005 ],
    "rhondda" => [ "Rhondda",66092 ],
    "ribble-valley" => [ "Ribble Valley",65579 ],
    "richmond-park" => [ "Richmond Park",65598 ],
    "richmond-yorks" => [ "Richmond (Yorks)",65722 ],
    "rochdale" => [ "Rochdale",65843 ],
    "rochester-and-strood" => [ "Rochester and Strood",66043 ],
    "rochford-and-southend-e" => [ "Rochford and Southend East",65584 ],
    "romford" => [ "Romford",66077 ],
    "romsey-and-southampton-n" => [ "Romsey and Southampton North",65884 ],
    "ross-skye-and-lochaber" => [ "Ross, Skye and Lochaber",14452 ],
    "rossendale-and-darwen" => [ "Rossendale and Darwen",66019 ],
    "rother-valley" => [ "Rother Valley",65930 ],
    "rotherham" => [ "Rotherham",66029 ],
    "rugby" => [ "Rugby",65656 ],
    "ruislip-northwood-and-pin" => [ "Ruislip, Northwood and Pinner",65681 ],
    "runnymede-and-weybridge" => [ "Runnymede and Weybridge",65589 ],
    "rushcliffe" => [ "Rushcliffe",65736 ],
    "rutherglen-and-hamilton-w" => [ "Rutherglen and Hamilton West",14453 ],
    "rutland-and-melton" => [ "Rutland and Melton",65833 ],
    "s-antrim" => [ "South Antrim",66137 ],
    "s-basildon-and-e-thurrock" => [ "South Basildon and East Thurrock",65962 ],
    "s-cambridgeshire" => [ "South Cambridgeshire",65922 ],
    "s-derbyshire" => [ "South Derbyshire",65762 ],
    "s-dorset" => [ "South Dorset",65788 ],
    "s-down" => [ "South Down",66138 ],
    "s-e-cambridgeshire" => [ "South East Cambridgeshire",65997 ],
    "s-e-cornwall" => [ "South East Cornwall",65684 ],
    "s-holland-and-the-deeping" => [ "South Holland and The Deepings",66051 ],
    "s-leicestershire" => [ "South Leicestershire",66034 ],
    "s-norfolk" => [ "South Norfolk",65666 ],
    "s-northamptonshire" => [ "South Northamptonshire",65902 ],
    "s-ribble" => [ "South Ribble",65951 ],
    "s-shields" => [ "South Shields",65719 ],
    "s-staffordshire" => [ "South Staffordshire",65943 ],
    "s-suffolk" => [ "South Suffolk",65614 ],
    "s-swindon" => [ "South Swindon",65800 ],
    "s-thanet" => [ "South Thanet",65829 ],
    "s-w-bedfordshire" => [ "South West Bedfordshire",65848 ],
    "s-w-devon" => [ "South West Devon",65775 ],
    "s-w-hertfordshire" => [ "South West Hertfordshire",65596 ],
    "s-w-norfolk" => [ "South West Norfolk",65652 ],
    "s-w-surrey" => [ "South West Surrey",65678 ],
    "s-w-wiltshire" => [ "South West Wiltshire",65956 ],
    "saffron-walden" => [ "Saffron Walden",65654 ],
    "salford-and-eccles" => [ "Salford and Eccles",65688 ],
    "salisbury" => [ "Salisbury",65889 ],
    "scarborough-and-whitby" => [ "Scarborough and Whitby",65891 ],
    "scunthorpe" => [ "Scunthorpe",66027 ],
    "sedgefield" => [ "Sedgefield",65763 ],
    "sefton-central" => [ "Sefton Central",65706 ],
    "selby-and-ainsty" => [ "Selby and Ainsty",65842 ],
    "sevenoaks" => [ "Sevenoaks",65698 ],
    "sheffield-brightside-and" => [ "Sheffield, Brightside and Hillsborough",65601 ],
    "sheffield-central" => [ "Sheffield Central",65957 ],
    "sheffield-hallam" => [ "Sheffield, Hallam",65741 ],
    "sheffield-heeley" => [ "Sheffield, Heeley",65549 ],
    "sheffield-s-e" => [ "Sheffield South East",65793 ],
    "sherwood" => [ "Sherwood",65632 ],
    "shipley" => [ "Shipley",65959 ],
    "shrewsbury-and-atcham" => [ "Shrewsbury and Atcham",65563 ],
    "sittingbourne-and-sheppey" => [ "Sittingbourne and Sheppey",65610 ],
    "skipton-and-ripon" => [ "Skipton and Ripon",65986 ],
    "sleaford-and-n-hykeham" => [ "Sleaford and North Hykeham",65920 ],
    "slough" => [ "Slough",65680 ],
    "solihull" => [ "Solihull",65879 ],
    "somerton-and-frome" => [ "Somerton and Frome",65812 ],
    "southampton-itchen" => [ "Southampton, Itchen",66016 ],
    "southampton-test" => [ "Southampton, Test",65580 ],
    "southend-w" => [ "Southend West",65876 ],
    "southport" => [ "Southport",65728 ],
    "spelthorne" => [ "Spelthorne",65942 ],
    "st-albans" => [ "St Albans",65715 ],
    "st-austell-and-newquay" => [ "St Austell and Newquay",65591 ],
    "st-helens-n" => [ "St Helens North",66073 ],
    "st-helens-s-and-whiston" => [ "St Helens South and Whiston",65732 ],
    "st-ives" => [ "St Ives",65854 ],
    "stafford" => [ "Stafford",66067 ],
    "staffordshire-moorlands" => [ "Staffordshire Moorlands",65907 ],
    "stalybridge-and-hyde" => [ "Stalybridge and Hyde",65960 ],
    "stevenage" => [ "Stevenage",65571 ],
    "stirling" => [ "Stirling",14454 ],
    "stockport" => [ "Stockport",65606 ],
    "stockton-n" => [ "Stockton North",65641 ],
    "stockton-s" => [ "Stockton South",65908 ],
    "stoke-on-trent-central" => [ "Stoke-on-Trent Central",65710 ],
    "stoke-on-trent-n" => [ "Stoke-on-Trent North",65783 ],
    "stoke-on-trent-s" => [ "Stoke-on-Trent South",65770 ],
    "stone" => [ "Stone",65950 ],
    "stourbridge" => [ "Stourbridge",65609 ],
    "strangford" => [ "Strangford",66139 ],
    "stratford-on-avon" => [ "Stratford-on-Avon",65648 ],
    "streatham" => [ "Streatham",66042 ],
    "stretford-and-urmston" => [ "Stretford and Urmston",65911 ],
    "stroud" => [ "Stroud",65858 ],
    "suffolk-coastal" => [ "Suffolk Coastal",65607 ],
    "sunderland-central" => [ "Sunderland Central",65586 ],
    "surrey-heath" => [ "Surrey Heath",65747 ],
    "sutton-and-cheam" => [ "Sutton and Cheam",66040 ],
    "sutton-coldfield" => [ "Sutton Coldfield",65703 ],
    "swansea-e" => [ "Swansea East",66091 ],
    "swansea-w" => [ "Swansea West",66118 ],
    "tamworth" => [ "Tamworth",65880 ],
    "tatton" => [ "Tatton",65964 ],
    "taunton-deane" => [ "Taunton Deane",65767 ],
    "telford" => [ "Telford",65992 ],
    "tewkesbury" => [ "Tewkesbury",65976 ],
    "the-cotswolds" => [ "The Cotswolds",65789 ],
    "the-wrekin" => [ "The Wrekin",65977 ],
    "thirsk-and-malton" => [ "Thirsk and Malton",65686 ],
    "thornbury-and-yate" => [ "Thornbury and Yate",65905 ],
    "thurrock" => [ "Thurrock",65919 ],
    "tiverton-and-honiton" => [ "Tiverton and Honiton",65761 ],
    "tonbridge-and-malling" => [ "Tonbridge and Malling",65744 ],
    "tooting" => [ "Tooting",65554 ],
    "torbay" => [ "Torbay",65692 ],
    "torfaen" => [ "Torfaen",66104 ],
    "torridge-and-w-devon" => [ "Torridge and West Devon",65904 ],
    "totnes" => [ "Totnes",65810 ],
    "tottenham" => [ "Tottenham",66074 ],
    "truro-and-falmouth" => [ "Truro and Falmouth",65659 ],
    "tunbridge-wells" => [ "Tunbridge Wells",65660 ],
    "twickenham" => [ "Twickenham",65782 ],
    "tynemouth" => [ "Tynemouth",65868 ],
    "upper-bann" => [ "Upper Bann",66140 ],
    "uxbridge-and-s-ruislip" => [ "Uxbridge and South Ruislip",65613 ],
    "vale-of-clwyd" => [ "Vale of Clwyd",66116 ],
    "vale-of-glamorgan" => [ "Vale of Glamorgan",66098 ],
    "vauxhall" => [ "Vauxhall",65825 ],
    "w-aberdeenshire-and-kinca" => [ "West Aberdeenshire and Kincardine",14455 ],
    "w-bromwich-e" => [ "West Bromwich East",65983 ],
    "w-bromwich-west" => [ "West Bromwich West",66047 ],
    "w-dorset" => [ "West Dorset",65716 ],
    "w-dunbartonshire" => [ "West Dunbartonshire",14456 ],
    "w-ham" => [ "West Ham",66058 ],
    "w-lancashire" => [ "West Lancashire",65873 ],
    "w-suffolk" => [ "West Suffolk",65629 ],
    "w-tyrone" => [ "West Tyrone",66141 ],
    "w-worcestershire" => [ "West Worcestershire",65758 ],
    "wakefield" => [ "Wakefield",65733 ],
    "wallasey" => [ "Wallasey",65635 ],
    "walsall-n" => [ "Walsall North",65890 ],
    "walsall-s" => [ "Walsall South",65832 ],
    "walthamstow" => [ "Walthamstow",65651 ],
    "wansbeck" => [ "Wansbeck",65631 ],
    "wantage" => [ "Wantage",65638 ],
    "warley" => [ "Warley",66079 ],
    "warrington-n" => [ "Warrington North",65874 ],
    "warrington-s" => [ "Warrington South",65916 ],
    "warwick-and-leamington" => [ "Warwick and Leamington",65608 ],
    "washington-and-sunderland" => [ "Washington and Sunderland West",66049 ],
    "watford" => [ "Watford",65626 ],
    "waveney" => [ "Waveney",66004 ],
    "wealden" => [ "Wealden",65961 ],
    "weaver-vale" => [ "Weaver Vale",65769 ],
    "wellingborough" => [ "Wellingborough",65830 ],
    "wells" => [ "Wells",65560 ],
    "welwyn-hatfield" => [ "Welwyn Hatfield",65740 ],
    "wentworth-and-dearne" => [ "Wentworth and Dearne",65588 ],
    "westminster-n" => [ "Westminster North",65851 ],
    "westmorland-and-lonsdale" => [ "Westmorland and Lonsdale",65963 ],
    "weston-super-mare" => [ "Weston-Super-Mare",65742 ],
    "wigan" => [ "Wigan",65612 ],
    "wimbledon" => [ "Wimbledon",65827 ],
    "winchester" => [ "Winchester",65921 ],
    "windsor" => [ "Windsor",65552 ],
    "wirral-s" => [ "Wirral South",65847 ],
    "wirral-w" => [ "Wirral West",65897 ],
    "witham" => [ "Witham",65831 ],
    "witney" => [ "Witney",65622 ],
    "woking" => [ "Woking",66039 ],
    "wokingham" => [ "Wokingham",65774 ],
    "wolverhampton-n-e" => [ "Wolverhampton North East",65777 ],
    "wolverhampton-s-e" => [ "Wolverhampton South East",65593 ],
    "wolverhampton-s-w" => [ "Wolverhampton South West",65948 ],
    "worcester" => [ "Worcester",65577 ],
    "workington" => [ "Workington",65625 ],
    "worsley-and-eccles-s" => [ "Worsley and Eccles South",65757 ],
    "worthing-w" => [ "Worthing West",65562 ],
    "wrexham" => [ "Wrexham",66113 ],
    "wycombe" => [ "Wycombe",66010 ],
    "wyre-and-preston-n" => [ "Wyre and Preston North",65695 ],
    "wyre-forest" => [ "Wyre Forest",66078 ],
    "wythenshawe-and-sale-e" => [ "Wythenshawe and Sale East",65669 ],
    "yeovil" => [ "Yeovil",65935 ],
    "ynys-mon" => [ "Ynys Môn",66115 ],
    "york-central" => [ "York Central",65965 ],
    "york-outer" => [ "York Outer",66037 ]
  }

  def getConstituencyByPC(postcode)
    pc = UKPostcode.new(postcode)
    if not pc.valid? or not pc.incode or not pc.outcode
      return false
    end
    uri = 'http://mapit.mysociety.org/postcode/'+pc.outcode+pc.incode
    begin
      # This will raise HTTPError if postcode is wrong
      jsondata = open(uri)
    rescue
      return nil
    end
    return JSON.load(jsondata)
  end
 
  def getConstituencyByCoords(lat,long)
    uri = 'http://mapit.mysociety.org/point/4326/'+long+','+lat+'?type=WMC'
    begin
      # This will raise HTTPError if postcode is wrong
      jsondata = open(uri)
    rescue
      return nil
    end
    return JSON.load(jsondata)
  end

  def getAllPredictions()
    uri = 'http://www.edu.lahti.fi/~zur/predictions-range.json'
    jsondata = open(uri)
    return JSON.load(jsondata)
  end

  def predictionRangeToValue(range)
    s = range.split('-')
    return (( s[0].to_i + s[1].to_f ) / 2).ceil
  end

  def makeRange(range)
    s = range.split('-')
    return s[0].to_i..s[1].to_i
  end

  def getPrediction(candidate, constituency)
    pred = @predictions.find { |c| c['name'] == constituency }
    if pred
      party = candidate['party']
      # In data, Scottish Greens are simply written in as Greens
      if party == 'Scottish Green Party'
        party = 'Green Party'
      end
      if not pred['parties'][party]
        return nil
      end
      # which party is doing best?
      means = {}
      pred['parties'].each { |k,v| means[k] = predictionRangeToValue(v) }
      ranges = {}
      pred['parties'].each { |k,v| ranges[k] = makeRange(v) }
      # Find range with highest upper limit
      max_range = ranges.values.max_by { |x| x.end }
      # Change displayed colour if ranges overlap
      if max_range.include?(ranges[party].end)
        maxval = true
      else
        maxval = false
      end
      return {'rangestring' => pred['parties'][party], 'value' => means[party], 'maxvalue' => maxval}
    end
    return nil
  end

  def getConstituencyByID(id)
    uri = 'http://mapit.mysociety.org/postcode/'+pc.outcode+pc.incode
    jsondata = open(uri)
    return JSON.load(jsondata)
  end

  def getMPid(candidate)
    # Is the best way to check this to look at the public whip identifier?
    for ide in candidate['identifiers']
      if ide['scheme'] == 'uk.org.publicwhip'
        # return numbers from end of the string
        return /[0-9]+$/.match(ide['identifier'])[0]
      end
    end
    return nil
  end

  def getPolicy(candidate, policyArea)
    party = candidate['party']
    if party == 'Independent'
      party = 'Independent - ' + candidate['name']
    end
    if CONSTITUENCY_POLICY.key?(@constituencyName) and CONSTITUENCY_POLICY[@constituencyName].key?(party)
      return CONSTITUENCY_POLICY[@constituencyName][party][policyArea]
    end
    if not PARTY_CONSTANTS.key?(party)
      party = 'Default'
    end
    if PARTY_CONSTANTS[party][policyArea].kind_of?(Array)
      return [['Party policy: ','']].concat(PARTY_CONSTANTS[party][policyArea])
    else
      return PARTY_CONSTANTS[party][policyArea]
    end
  end

  def getAllPolicies(candidates)
    policies = Hash.new
    for candidate in candidates
      policies[candidate['id']] = Hash.new
      for policy in POLICY_AREAS
        policies[candidate['id']][policy] = getPolicy(candidate, policy)
      end
    end
    return policies
  end

  def getImageUrl(candidate, twitter_obj)
    if candidate['image']
      return candidate['image']
    end
    if candidate['twitter_username'].length > 2
      begin
        twitter_user = twitter_obj.user(candidate['twitter_username'])
      rescue Twitter::Error::NotFound
        candidate['twitter_username'] = ''
        return nil
      end
      twitter_profile_uri = twitter_user.profile_image_uri.to_s.sub("_normal", "")
      if not twitter_profile_uri =~ /default_profile_images/
        return twitter_profile_uri
      end
    end
  end

  def getPreviousResults(candidate, const_name)
    const = Constituency.find_by_name(const_name)
    party = candidate['party']
    # In data, Scottish Greens are simply written in as Greens
    if party == 'Scottish Green Party'
      party = 'Green Party'
    end
    # Add special case for Independents here too
    if party == 'Independent'
      party = 'Independent - '+candidate['name']
    end
    if const.parties.has_key?(party)
      # Special way independents are coded
      return const.parties[party]
    else
      return nil
    end
  end

  def getPreviousElectionYear(candidates)
    for c in candidates
      if c['previousVote'] and c['previousVote']['year']
        return c['previousVote']['year']
      end
    end
  end

  def isEmptyCandidate(c)
    if c['MPid']
      return false
    elsif c['twitter_username'] and c['twitter_username'].length > 2
      return false
    elsif c['facebook_personal_url'] and c['facebook_personal_url'].length > 5
      return false
    elsif c['homepage_url'] and c['homepage_url'].length > 5
      return false
    elsif c['party_ppc_page_url'] and c['party_ppc_page_url'].length > 5
      return false
    elsif c['wikipedia_url'] and c['wikipedia_url'].length > 5
      return false
    elsif c['email'] and c['email'].length > 5
      return false
    end
    return true
  end

  def getCandidates(constituencyId, constituencyName)
    uri = 'http://yournextmp.popit.mysociety.org/api/v0.1/posts/'+constituencyId.to_s+'?embed=membership.person'
    twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key = 'vzUdH63VDtZX1AQiUNBPpL0Sj'
      config.consumer_secret = 'gosJYtqmDduobc4QWVo4xL56ykro1sBvQlVbZVnuHwkxhwZFVd'
      config.access_token = '3006172181-DiGGfRtjGyHvwpl1k8jaR4o3uPEW2GQRdZwLwB0'
      config.access_token_secret = 'MCmGUPGi4jpMZS7795FRGp6JXdtDKwNr8EedbMzUY4JOA'
    end
    jsondata = open(uri)
    @data = JSON.load(jsondata)
    @candidates = []
    for cand in @data['result']['memberships']
      @currentConstituency = cand['person_id']['versions'][0]['data']['standing_in']['2015']
      if @currentConstituency and @currentConstituency['post_id'] == constituencyId.to_s
        # merge to make sure versions[0][data] is easily accessible in object - not ideal!
        @candidates.concat([cand['person_id']['versions'][0]['data'].merge(cand['person_id'])])
      end
    end
    # For some reason there are duplicates in the JSON
    @candidates = @candidates.uniq
    for i in @candidates.each_index()
      @candidates[i]['image_url'] = getImageUrl(@candidates[i], twitter_client)
      @candidates[i]['party'] = @candidates[i]['party_memberships']['2015']['name']
      @candidates[i]['isEmpty'] = isEmptyCandidate(@candidates[i])
      if PARTY_REPLACE_STRINGS[@candidates[i]['party']]
        @candidates[i]['party'] = PARTY_REPLACE_STRINGS[@candidates[i]['party']]
      end
      @candidates[i]['previousVote'] = getPreviousResults(@candidates[i], constituencyName)
      @candidates[i]['prediction2015'] = getPrediction(@candidates[i], constituencyName)
      @candidates[i]['MPid'] = getMPid(@candidates[i])
    end
    return @candidates
  end

  def getCandidateById(id)
    uri = 'http://yournextmp.popit.mysociety.org/api/v0.1/search/persons?q=id:'+id.to_s
    jsondata = open(uri)
    @data = JSON.load(jsondata)
    return @data['result'][0]
  end

  def getTwitterCount(candidates)
    count = 0
    for c in candidates
      if c['twitter_username'] and c['twitter_username'].length > 2
        count = count + 1
      end
    end
    return count
  end
    
  def search
    if not request['q'] and not request['lat']
      redirect_to "/?error" and return
    end
    if request['lat']
      @condata = getConstituencyByCoords(request['lat'],request['long'])
      if not @condata.length > 0
        # flash[:alert] = "Location not in the UK?"
        redirect_to "/?err2" and return
      end
      @conId = @condata.keys[0].to_i
    else
      @q = request['q']
      @condata = getConstituencyByPC(@q)
      if not @condata
        # flash[:alert] = "Invalid post code, please try again"
        redirect_to "/?error" and return
      end
      @conId = @condata['shortcuts']['WMC']
    end
    redirect_to "/constituencies/"+TWITTER_LIST[@conId] and return
  end

  def index
    # TODO: This bit can be removed later..
    if request['q']
      @q = request['q']
      @condata = getConstituencyByPC(@q)
      if not @condata
        # flash[:alert] = "Invalid post code, please try again"
        redirect_to "/?error" and return
      end
      @conId = @condata['shortcuts']['WMC']
      @constituencyName = @condata['areas'][@conId.to_s]['name']
    elsif request['name']
      @constituencyName = CONSTITUENCY_LIST[request['name']][0]
      if not @constituencyName
        raise ActionController::RoutingError.new('Not Found')
      end
      @conId = CONSTITUENCY_LIST[request['name']][1]
    else
      # flash[:alert] = "Invalid post code, please try again"
      redirect_to "/?error" and return
    end
    @twitter_list = TWITTER_LIST[@conId]
    @predictions = Rails.cache.fetch('predictions', expires_in: 24.hours) { getAllPredictions() }
    @candidates = Rails.cache.fetch('candidates-'+@conId.to_s, expires_in: 24.hours) { getCandidates(@conId, @constituencyName) }
    @previousElectionYear = getPreviousElectionYear(@candidates)
    @twitter_count = getTwitterCount(@candidates)
    @policies = getAllPolicies(@candidates)
    @PARTY_CONSTANTS = PARTY_CONSTANTS
  end

  def constituencies
    @constituency_hash = CONSTITUENCY_LIST
  end

  def show
    @candidate = getCandidateById(request['id'])
  end
end
