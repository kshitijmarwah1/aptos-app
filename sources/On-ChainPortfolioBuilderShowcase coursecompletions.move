module MyModule::PortfolioBuilder {
    use aptos_framework::signer;
    use std::string::{Self, String};
    use std::vector;

    /// Struct representing a course completion certificate
    struct Certificate has store, drop, copy {
        course_name: String,
        completion_date: u64,
        issuer: String,
        grade: u8, // Grade out of 100
    }

    /// Struct representing a user's portfolio
    struct Portfolio has store, key {
        owner: address,
        certificates: vector<Certificate>,
        total_courses: u64,
    }

    /// Error codes
    const E_PORTFOLIO_NOT_FOUND: u64 = 1;
    const E_INVALID_GRADE: u64 = 2;

    /// Function to create a new portfolio for a user
    public fun create_portfolio(owner: &signer) {
        let owner_addr = signer::address_of(owner);
        let portfolio = Portfolio {
            owner: owner_addr,
            certificates: vector::empty<Certificate>(),
            total_courses: 0,
        };
        move_to(owner, portfolio);
    }

    /// Function to add a course completion certificate to the portfolio
    public fun add_certificate(
        owner: &signer,
        course_name: String,
        completion_date: u64,
        issuer: String,
        grade: u8
    ) acquires Portfolio {
        // Validate grade is between 0 and 100
        assert!(grade <= 100, E_INVALID_GRADE);
        
        let owner_addr = signer::address_of(owner);
        
        // Check if portfolio exists
        assert!(exists<Portfolio>(owner_addr), E_PORTFOLIO_NOT_FOUND);
        
        let portfolio = borrow_global_mut<Portfolio>(owner_addr);
        
        let certificate = Certificate {
            course_name,
            completion_date,
            issuer,
            grade,
        };
        
        vector::push_back(&mut portfolio.certificates, certificate);
        portfolio.total_courses = portfolio.total_courses + 1;
    }
}